//
//  PortfolioViewModelTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

@MainActor
struct PortfolioViewModelTests {
    private let repository = MockCoinRepository()
    private let firestore = MockPortfolioFirestoreService()
    private let coinService: CoinService
    private let viewModel: PortfolioViewModel
    
    init(signedIn: Bool = true) throws {
        coinService = CoinService(repository: repository)
        viewModel = PortfolioViewModel(firestoreService: firestore,
                                       coinService: coinService,
                                       currentUserID: { signedIn ? "user-1" : nil })
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 100)])
    }
    
    private func loadPrices() async throws {
        try await coinService.forceRefresh()
    }
    
    // MARK: - Buying
    
    @Test func buyCreatesHoldingAndTransactionInOneCommit() async throws {
        try await loadPrices()
        
        try await viewModel.buy(coinId: "bitcoin", quantity: 2)
        
        #expect(viewModel.holdings.count == 1)
        #expect(viewModel.holdings[0].quantity == 2)
        #expect(viewModel.holdings[0].averagePurchasePrice == 100)
        #expect(viewModel.transactions.count == 1)
        #expect(viewModel.transactions[0].type == .buy)
        
        #expect(firestore.commits.count == 1)
        #expect(firestore.commits[0].userId == "user-1")
        #expect(firestore.commits[0].holding.quantity == 2)
    }
    
    /// The price used must be the live one at the time of the trade, not one captured earlier.
    @Test func secondBuyUsesTheNewPriceAndAveragesIt() async throws {
        try await loadPrices()
        try await viewModel.buy(coinId: "bitcoin", quantity: 1)
        
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 200)])
        try await coinService.forceRefresh()
        try await viewModel.buy(coinId: "bitcoin", quantity: 1)
        
        #expect(viewModel.holdings.count == 1)
        #expect(viewModel.holdings[0].quantity == 2)
        #expect(viewModel.holdings[0].averagePurchasePrice == 150)
        #expect(viewModel.transactions.first?.price == 200) // newest first
    }
    
    @Test func failedWriteLeavesLocalStateUntouched() async throws {
        try await loadPrices()
        firestore.error = MockFirestoreFailure()
        
        await #expect(throws: PortfolioError.transactionFailed) {
            try await viewModel.buy(coinId: "bitcoin", quantity: 1)
        }
        
        #expect(viewModel.holdings.isEmpty)
        #expect(viewModel.transactions.isEmpty)
        #expect(!viewModel.isLoading)
    }
    
    @Test func buyingWithoutAPriceIsRefused() async throws {
        // Prices were never loaded, so there is nothing to trade at
        await #expect(throws: PortfolioError.priceUnavailable) {
            try await viewModel.buy(coinId: "bitcoin", quantity: 1)
        }
    }
    
    @Test func buyingZeroIsRefused() async throws {
        try await loadPrices()
        
        await #expect(throws: PortfolioError.invalidQuantity) {
            try await viewModel.buy(coinId: "bitcoin", quantity: 0)
        }
    }
    
    // MARK: - Selling
    
    @Test func partialSellKeepsTheHoldingAndRecordsATransaction() async throws {
        try await loadPrices()
        try await viewModel.buy(coinId: "bitcoin", quantity: 2)
        
        try await viewModel.sell(coinId: "bitcoin", quantity: 1)
        
        #expect(viewModel.holdings[0].quantity == 1)
        #expect(viewModel.transactions.first?.type == .sell)
        #expect(firestore.commits.count == 2)
        #expect(firestore.commits[1].holding.quantity == 1)
    }
    
    @Test func sellingEverythingRemovesTheHoldingButKeepsTheHistory() async throws {
        try await loadPrices()
        try await viewModel.buy(coinId: "bitcoin", quantity: 2)
        
        try await viewModel.sell(coinId: "bitcoin", quantity: 2)
        
        #expect(viewModel.holdings.isEmpty)
        #expect(viewModel.transactions.count == 2)
        // A zero-quantity holding in the commit is what makes Firestore delete the document
        #expect(firestore.commits[1].holding.quantity == 0)
    }
    
    @Test func failedSellLeavesTheHoldingUntouched() async throws {
        try await loadPrices()
        try await viewModel.buy(coinId: "bitcoin", quantity: 2)
        firestore.error = MockFirestoreFailure()
        
        await #expect(throws: PortfolioError.transactionFailed) {
            try await viewModel.sell(coinId: "bitcoin", quantity: 1)
        }
        
        #expect(viewModel.holdings[0].quantity == 2)
        #expect(viewModel.transactions.count == 1)
    }
    
    @Test func cannotSellMoreThanOwned() async throws {
        try await loadPrices()
        try await viewModel.buy(coinId: "bitcoin", quantity: 1)
        
        await #expect(throws: PortfolioError.insufficientHoldings) {
            try await viewModel.sell(coinId: "bitcoin", quantity: 2)
        }
        #expect(viewModel.holdings[0].quantity == 1)
    }
    
    @Test func cannotSellACoinThatIsNotOwned() async throws {
        try await loadPrices()
        
        await #expect(throws: PortfolioError.holdingNotFound) {
            try await viewModel.sell(coinId: "bitcoin", quantity: 1)
        }
    }
    
    // MARK: - Account
    
    @Test func tradingRequiresASignedInUser() async throws {
        let signedOut = try PortfolioViewModelTests(signedIn: false)
        try await signedOut.loadPrices()
        
        await #expect(throws: PortfolioError.userNotAuthenticated) {
            try await signedOut.viewModel.buy(coinId: "bitcoin", quantity: 1)
        }
    }
    
    // MARK: - Totals
    
    @Test func totalsUseLivePrices() async throws {
        try await loadPrices()
        try await viewModel.buy(coinId: "bitcoin", quantity: 2) // invested 200
        
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 150)])
        try await coinService.forceRefresh()
        
        #expect(viewModel.totalInvestment() == 200)
        #expect(viewModel.totalPortfolioValue() == 300)
        #expect(viewModel.totalProfitLoss() == 100)
        #expect(viewModel.totalProfitLossPercentage() == 50)
    }
    
    @Test func loadingThePortfolioFetchesPricesForCoinsOutsideTheTopList() async throws {
        firestore.holdingsToLoad = [
            Holding(coinId: "dogecoin", coinSymbol: "doge", quantity: 10, purchasePrice: 1, date: .now, imageUrl: "")
        ]
        repository.idsResult = .success([try TestFixtures.coin(id: "dogecoin", price: 2)])
        try await loadPrices()
        
        await viewModel.loadPortfolioData()
        
        #expect(repository.requestedIDs == [["dogecoin"]])
        #expect(viewModel.getCurrentPrice(for: "dogecoin") == 2)
        #expect(viewModel.totalPortfolioValue() == 20)
    }
}
