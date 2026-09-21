//
//  PortfolioTotalsTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

/// Portfolio value, profit/loss and distribution, computed from live prices.
@MainActor
struct PortfolioTotalsTests {
    private let repository = MockCoinRepository()
    private let firestore = MockPortfolioFirestoreService()
    private let coinService: CoinService
    private let viewModel: PortfolioViewModel

    init() {
        coinService = CoinService(repository: repository)
        viewModel = PortfolioViewModel(firestoreService: firestore,
                                       coinService: coinService,
                                       currentUserID: { "user-1" })
    }

    private func setPrices(_ prices: [(id: String, price: Double)]) async throws {
        repository.serve(try prices.map { try TestFixtures.coin(id: $0.id, price: $0.price) })
        try await coinService.forceRefresh()
    }

    // MARK: - Totals

    @Test func anEmptyPortfolioIsWorthNothing() {
        #expect(viewModel.totalPortfolioValue() == 0)
        #expect(viewModel.totalInvestment() == 0)
        #expect(viewModel.totalProfitLoss() == 0)
        #expect(viewModel.totalProfitLossPercentage() == 0) // no division by zero
    }

    @Test func aRisingPriceShowsAsProfit() async throws {
        try await setPrices([("bitcoin", 100)])
        try await viewModel.buy(coinId: "bitcoin", quantity: 2)

        try await setPrices([("bitcoin", 150)])

        #expect(viewModel.totalInvestment() == 200)
        #expect(viewModel.totalPortfolioValue() == 300)
        #expect(viewModel.totalProfitLoss() == 100)
        #expect(viewModel.totalProfitLossPercentage() == 50)
    }

    @Test func aFallingPriceShowsAsLoss() async throws {
        try await setPrices([("bitcoin", 100)])
        try await viewModel.buy(coinId: "bitcoin", quantity: 1)

        try await setPrices([("bitcoin", 80)])

        #expect(viewModel.totalProfitLoss() == -20)
        #expect(viewModel.totalProfitLossPercentage() == -20)
    }

    @Test func totalsAddUpAcrossCoins() async throws {
        try await setPrices([("bitcoin", 100), ("ethereum", 10)])
        try await viewModel.buy(coinId: "bitcoin", quantity: 1)
        try await viewModel.buy(coinId: "ethereum", quantity: 5)

        #expect(viewModel.totalInvestment() == 150)
        #expect(viewModel.totalPortfolioValue() == 150)
    }

    // MARK: - Missing prices

    /// A coin with no market price is valued at what it was bought for, so it doesn't drop out of the totals.
    @Test func aCoinWithoutAPriceIsValuedAtItsBuyPrice() async {
        let ghost = Holding(coinId: "ghost", coinSymbol: "GHO", quantity: 3, purchasePrice: 10, date: .now, imageUrl: "")
        firestore.holdingsToLoad = [ghost]
        await viewModel.loadPortfolioData()

        #expect(viewModel.currentPrice(for: ghost) == 10)
        #expect(viewModel.totalPortfolioValue() == 30)
        #expect(viewModel.totalProfitLoss() == 0)
    }

    // MARK: - Distribution

    @Test func distributionIsLargestFirstAndAddsUpToOneHundredPercent() async throws {
        try await setPrices([("bitcoin", 100), ("ethereum", 300)])
        try await viewModel.buy(coinId: "bitcoin", quantity: 2) // worth 200
        try await viewModel.buy(coinId: "ethereum", quantity: 1) // worth 300

        let slices = viewModel.distribution()

        #expect(slices.map(\.coinSymbol) == ["ETHEREUM", "BITCOIN"])
        #expect(slices.map(\.percentage) == [60, 40])
        #expect(slices.map(\.value) == [300, 200])
    }

    @Test func distributionOfAnEmptyPortfolioIsEmpty() {
        #expect(viewModel.distribution().isEmpty)
    }
}
