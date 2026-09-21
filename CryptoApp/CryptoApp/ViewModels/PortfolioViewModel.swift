//
//  PortfolioViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 15/08/2025.
//

import Foundation
import os

@MainActor
protocol PortfolioViewModelProtocol: Observable {
    var holdings: [Holding] { get }
    var transactions: [Transaction] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func loadPortfolioData() async
    func clearLocalData()
    func clearError()
    /// Buys `quantity` of a coin at its current market price. Throws a `PortfolioError` on failure.
    func buy(coinId: String, quantity: Decimal) async throws
    /// Sells `quantity` of a coin at its current market price. Throws a `PortfolioError` on failure.
    func sell(coinId: String, quantity: Decimal) async throws
    func getCurrentPrice(for coinId: String) -> Decimal?
    func getTotalHolding(for coinId: String) -> Decimal

    func totalPortfolioValue() -> Decimal
    func totalInvestment() -> Decimal
    func totalProfitLoss() -> Decimal
    func totalProfitLossPercentage() -> Decimal

    var holdingsCount: Int { get }
    var transactionCount: Int { get }
}

@MainActor
@Observable
final class PortfolioViewModel: PortfolioViewModelProtocol {
    // STATE - What the UI displays
    private(set) var holdings: [Holding] = []
    private(set) var transactions: [Transaction] = []
    private(set) var isLoading = false
    /// Error from loading portfolio data. Trades report their errors by throwing instead.
    private(set) var lastError: PortfolioError?

    // Helper for UI error display
    var errorMessage: String? {
        lastError?.localizedDescription
    }

    // DEPENDENCIES - Services this ViewModel needs
    private let firestoreService: PortfolioFirestoreServiceProtocol
    private let coinService: CoinServiceProtocol
    private let currentUserID: @MainActor () -> String?
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CryptoApp", category: "Portfolio")

    // INITIALIZATION - `currentUserID` is a closure so tests don't need a signed-in Firebase user
    init(firestoreService: PortfolioFirestoreServiceProtocol,
         coinService: CoinServiceProtocol,
         currentUserID: @escaping @MainActor () -> String?) {
        self.firestoreService = firestoreService
        self.coinService = coinService
        self.currentUserID = currentUserID
    }

    convenience init(firestoreService: PortfolioFirestoreServiceProtocol = PortfolioFirestoreService(),
                     authService: AuthService,
                     coinService: CoinServiceProtocol) {
        self.init(firestoreService: firestoreService,
                  coinService: coinService,
                  currentUserID: { authService.userSession?.uid })
    }

    // LOAD DATA - Get user's portfolio from Firestore
    func loadPortfolioData() async {
        guard let userId = currentUserID() else {
            lastError = .userNotAuthenticated
            return
        }

        isLoading = true
        defer { isLoading = false }

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
    }

    func clearError() {
        lastError = nil
    }

    /// Get current price for a specific coin
    func getCurrentPrice(for coinId: String) -> Decimal? {
        coinService.coin(id: coinId).map { Decimal(price: $0.currentPrice) }
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
            let currentPrice = getCurrentPrice(for: holding.coinId) ?? holding.averagePurchasePrice
            return total + holding.currentValue(currentPrice: currentPrice)
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

    var holdingsCount: Int {
        holdings.count
    }

    var transactionCount: Int {
        transactions.count
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
