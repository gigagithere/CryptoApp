//
//  TradeViewModelTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

@MainActor
struct TradeViewModelTests {
    private let repository = MockCoinRepository()
    private let firestore = MockPortfolioFirestoreService()
    private let coinService: CoinService
    private let portfolio: PortfolioViewModel

    init() throws {
        coinService = CoinService(repository: repository)
        portfolio = PortfolioViewModel(firestoreService: firestore,
                                       coinService: coinService,
                                       currentUserID: { "user-1" })
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 100)])
    }

    // MARK: - Input

    @Test func startsWithOneCoin() {
        let trade = TradeViewModel(coinID: "bitcoin", type: .buy)

        #expect(trade.quantity == 1)
        #expect(trade.canSubmit)
    }

    @Test(arguments: [nil, 0, -1] as [Decimal?])
    func cannotSubmitWithoutAPositiveQuantity(quantity: Decimal?) {
        let trade = TradeViewModel(coinID: "bitcoin", type: .buy)
        trade.quantity = quantity

        #expect(!trade.canSubmit)
    }

    @Test func totalIsQuantityTimesPrice() {
        let trade = TradeViewModel(coinID: "bitcoin", type: .buy)
        trade.quantity = 2.5

        #expect(trade.total(at: 100) == 250)
    }

    // MARK: - Executing

    @Test func buyingAddsToThePortfolio() async throws {
        try await coinService.forceRefresh()
        let trade = TradeViewModel(coinID: "bitcoin", type: .buy)
        trade.quantity = 2

        try await trade.execute(using: portfolio)

        #expect(portfolio.holdings.first?.quantity == 2)
        #expect(!trade.isProcessing)
    }

    @Test func sellingRemovesFromThePortfolio() async throws {
        try await coinService.forceRefresh()
        try await portfolio.buy(coinId: "bitcoin", quantity: 3)
        let trade = TradeViewModel(coinID: "bitcoin", type: .sell)
        trade.quantity = 1

        try await trade.execute(using: portfolio)

        #expect(portfolio.holdings.first?.quantity == 2)
    }

    @Test func failureIsThrownAndProcessingEnds() async throws {
        try await coinService.forceRefresh()
        firestore.error = MockFirestoreFailure()
        let trade = TradeViewModel(coinID: "bitcoin", type: .buy)

        await #expect(throws: PortfolioError.transactionFailed) {
            try await trade.execute(using: portfolio)
        }

        #expect(!trade.isProcessing)
        #expect(portfolio.holdings.isEmpty)
    }

    @Test func emptyQuantityIsRefusedWithoutTouchingTheServer() async throws {
        try await coinService.forceRefresh()
        let trade = TradeViewModel(coinID: "bitcoin", type: .buy)
        trade.quantity = nil

        await #expect(throws: PortfolioError.invalidQuantity) {
            try await trade.execute(using: portfolio)
        }

        #expect(firestore.commits.isEmpty)
    }
}
