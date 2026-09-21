//
//  MockPortfolioFirestoreService.swift
//  CryptoAppTests
//

import Foundation
@testable import CryptoApp

/// Records what would be written to Firestore, and can be told to fail.
///
/// `@unchecked Sendable`: a test double whose properties are only touched from the test's own (main actor) code.
final class MockPortfolioFirestoreService: PortfolioFirestoreServiceProtocol, @unchecked Sendable {
    struct Commit {
        let userId: String
        let transaction: CryptoApp.Transaction
        let holding: Holding
    }
    
    var holdingsToLoad: [Holding] = []
    var transactionsToLoad: [CryptoApp.Transaction] = []
    var error: Error?
    
    private(set) var commits: [Commit] = []
    
    func loadHoldings(userId: String) async throws -> [Holding] {
        if let error { throw error }
        return holdingsToLoad
    }
    
    func loadTransactions(userId: String) async throws -> [CryptoApp.Transaction] {
        if let error { throw error }
        return transactionsToLoad
    }
    
    func commitTrade(userId: String, transaction: CryptoApp.Transaction, holding: Holding) async throws {
        if let error { throw error }
        commits.append(Commit(userId: userId, transaction: transaction, holding: holding))
    }
}

struct MockFirestoreFailure: Error {}
