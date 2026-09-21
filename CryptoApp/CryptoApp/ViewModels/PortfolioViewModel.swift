//
//  PortfolioViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 15/08/2025.
//

import Foundation
import os

@Observable
final class PortfolioViewModel {
    // STATE - What the UI displays
    private(set) var holdings: [Holding] = []
    private(set) var transactions: [Transaction] = []
    private(set) var isLoading = false
    /// True once the first load has finished, successfully or not. Until then the screen shows a spinner, not "empty".
    private(set) var hasLoaded = false
    /// Error from loading portfolio data. Trades report their errors by throwing instead.
    private(set) var lastError: PortfolioError?

    // Helper for UI error display
    var errorMessage: String? {
        lastError?.localizedDescription
    }

    // DEPENDENCIES - Services this ViewModel needs
    private let firestoreService: PortfolioFirestoreServiceProtocol
    private let coinService: CoinService
    private let currentUserID: @MainActor () -> String?
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CryptoApp", category: "Portfolio")

    // INITIALIZATION - `currentUserID` is a closure so tests don't need a signed-in Firebase user
    init(firestoreService: PortfolioFirestoreServiceProtocol,
         coinService: CoinService,
         currentUserID: @escaping @MainActor () -> String?) {
        self.firestoreService = firestoreService
        self.coinService = coinService
        self.currentUserID = currentUserID
    }

    convenience init(firestoreService: PortfolioFirestoreServiceProtocol = PortfolioFirestoreService(),
                     authService: AuthService,
                     coinService: CoinService) {
        self.init(firestoreService: firestoreService,
                  coinService: coinService,
                  currentUserID: { authService.userID })
    }

    // LOAD DATA - Get user's portfolio from Firestore
    func loadPortfolioData() async {
        guard let userId = currentUserID() else {
            lastError = .userNotAuthenticated
            return
        }

        isLoading = true
        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            // Load both holdings and transactions concurrently
            async let holdingsResult = firestoreService.loadHoldings(userId: userId)
            async let transactionsResult = firestoreService.loadTransactions(userId: userId)

            holdings = try await holdingsResult
            transactions = try await transactionsResult
            lastError = nil
        } catch {
            Self.logger.error("Loading portfolio failed: \(error.localizedDescription, privacy: .public)")
            lastError = .firestoreLoadFailed
            return
        }

        // Holdings that dropped out of the top list still need a price
        await coinService.loadMissingCoins(ids: holdings.map(\.coinId))
    }

    // CLEAR LOCAL DATA - Remove cached data when user logs out
    func clearLocalData() {
        holdings = []
        transactions = []
        lastError = nil
        hasLoaded = false
    }

    /// Get current price for a specific coin
    func getCurrentPrice(for coinId: String) -> Decimal? {
        coinService.coin(id: coinId).map { Decimal(price: $0.currentPrice) }
    }

    /// The live price of a held coin; falls back to the average buy price when no market price is known.
    func currentPrice(for holding: Holding) -> Decimal {
        getCurrentPrice(for: holding.coinId) ?? holding.averagePurchasePrice
    }

    // BUY - The price is read from the live market data at the moment of the trade
    func buy(coinId: String, quantity: Decimal) async throws {
        let userId = try requireUserID()
        guard quantity > 0 else { throw PortfolioError.invalidQuantity }
        guard let coin = coinService.coin(id: coinId) else { throw PortfolioError.priceUnavailable }

        isLoading = true
        defer { isLoading = false }

        let price = Decimal(price: coin.currentPrice)
        let date = Date.now

        // Work on copies: local state only changes after the write succeeded
        var holding: Holding
        if var existing = holdings.first(where: { $0.coinId == coinId }) {
            existing.addPurchase(quantity: quantity, purchasePrice: price, date: date)
            holding = existing
        } else {
            holding = Holding(coinId: coin.id, coinSymbol: coin.symbol, quantity: quantity,
                              purchasePrice: price, date: date, imageUrl: coin.image)
        }
        let transaction = Transaction(coinId: coin.id, coinSymbol: coin.symbol, quantity: quantity,
                                      price: price, type: .buy, date: date, imageUrl: coin.image)

        try await commit(transaction, updating: holding, userId: userId)

        upsert(holding)
        transactions.insert(transaction, at: 0)
    }

    // SELL - Average-cost accounting: selling reduces the holding, its average buy price stays the same
    func sell(coinId: String, quantity: Decimal) async throws {
        let userId = try requireUserID()
        guard quantity > 0 else { throw PortfolioError.invalidQuantity }
        guard var holding = holdings.first(where: { $0.coinId == coinId }) else { throw PortfolioError.holdingNotFound }
        guard let price = getCurrentPrice(for: coinId) else { throw PortfolioError.priceUnavailable }
        guard holding.removePurchase(quantity: quantity) else { throw PortfolioError.insufficientHoldings }

        isLoading = true
        defer { isLoading = false }

        let transaction = Transaction(coinId: coinId, coinSymbol: holding.coinSymbol, quantity: quantity,
                                      price: price, type: .sell, date: .now, imageUrl: holding.imageUrl)

        try await commit(transaction, updating: holding, userId: userId)

        if holding.quantity > 0 {
            upsert(holding)
        } else {
            holdings.removeAll { $0.coinId == coinId }
        }
        transactions.insert(transaction, at: 0)
    }

    func getTotalHolding(for coinId: String) -> Decimal {
        holdings.first(where: { $0.coinId == coinId })?.quantity ?? 0
    }

    // PORTFOLIO CALCULATIONS - Using live market prices
    func totalPortfolioValue() -> Decimal {
        holdings.reduce(0) { total, holding in
            total + holding.currentValue(currentPrice: currentPrice(for: holding))
        }
    }

    func totalInvestment() -> Decimal {
        holdings.reduce(0) { total, holding in
            total + holding.totalInvested
        }
    }

    func totalProfitLoss() -> Decimal {
        totalPortfolioValue() - totalInvestment()
    }

    func totalProfitLossPercentage() -> Decimal {
        let investment = totalInvestment()
        guard investment > 0 else { return 0 }

        return ((totalPortfolioValue() - investment) / investment) * 100
    }

    /// Each holding's share of the portfolio value, largest first.
    func distribution() -> [DistributionData] {
        let values = holdings
            .map { (symbol: $0.coinSymbol.uppercased(), value: $0.currentValue(currentPrice: currentPrice(for: $0)).doubleValue) }
            .sorted { $0.value > $1.value }
        let total = values.reduce(0) { $0 + $1.value }

        return values.map {
            DistributionData(coinSymbol: $0.symbol, value: $0.value, percentage: total > 0 ? $0.value / total * 100 : 0)
        }
    }

    // MARK: - Private

    private func requireUserID() throws -> String {
        guard let userId = currentUserID() else { throw PortfolioError.userNotAuthenticated }
        return userId
    }

    private func commit(_ transaction: Transaction, updating holding: Holding, userId: String) async throws {
        do {
            try await firestoreService.commitTrade(userId: userId, transaction: transaction, holding: holding)
        } catch {
            Self.logger.error("Trade failed: \(error.localizedDescription, privacy: .public)")
            throw PortfolioError.transactionFailed
        }
    }

    private func upsert(_ holding: Holding) {
        if let index = holdings.firstIndex(where: { $0.coinId == holding.coinId }) {
            holdings[index] = holding
        } else {
            holdings.append(holding)
        }
    }
}
