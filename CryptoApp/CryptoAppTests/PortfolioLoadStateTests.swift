//
//  PortfolioLoadStateTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

/// The portfolio screen shows a spinner until the first load has finished, so it never flashes "empty".
@MainActor
struct PortfolioLoadStateTests {
    private let firestore = MockPortfolioFirestoreService()
    private let viewModel: PortfolioViewModel

    init() {
        viewModel = PortfolioViewModel(firestoreService: firestore,
                                       coinService: CoinService(repository: MockCoinRepository()),
                                       currentUserID: { "user-1" })
    }

    @Test func startsNotLoaded() {
        #expect(!viewModel.hasLoaded)
    }

    @Test func isLoadedAfterASuccessfulLoad() async {
        await viewModel.loadPortfolioData()

        #expect(viewModel.hasLoaded)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func isLoadedAfterAFailedLoadToo() async {
        firestore.error = MockFirestoreFailure()

        await viewModel.loadPortfolioData()

        #expect(viewModel.hasLoaded) // the screen switches from spinner to the error state
        #expect(viewModel.errorMessage != nil)
    }

    @Test func signingOutStartsOver() async {
        await viewModel.loadPortfolioData()

        viewModel.clearLocalData()

        #expect(!viewModel.hasLoaded)
    }
}
