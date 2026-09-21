//
//  PortfolioFirestoreService.swift
//  CryptoApp
//
//  Created by Claude on 16/08/2025.
//

import Foundation
import FirebaseFirestore

// PROTOCOL - Defines what portfolio storage operations are available
protocol PortfolioFirestoreServiceProtocol {
    func loadHoldings(userId: String) async throws -> [Holding]
    func saveHolding(userId: String, holding: Holding) async throws
    func deleteHolding(userId: String, coinId: String) async throws
    func loadTransactions(userId: String) async throws -> [Transaction]
    func saveTransaction(userId: String, transaction: Transaction) async throws
    func saveTransactionAndHolding(userId: String, transaction: Transaction, holding: Holding) async throws
    func deleteAllUserData(userId: String) async throws
}

// PORTFOLIO FIRESTORE SERVICE - Handles all portfolio data operations with Firestore
class PortfolioFirestoreService: PortfolioFirestoreServiceProtocol {
    private let db = Firestore.firestore()
    
    // LOAD USER'S HOLDINGS - Get all coins the user owns
    func loadHoldings(userId: String) async throws -> [Holding] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("holdings")
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Holding.self)
        }
    }
    
    // SAVE HOLDING - Store or update a user's coin holding
    func saveHolding(userId: String, holding: Holding) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("holdings")
            .document(holding.coinId)
            .setData(from: holding)
    }
    
    // DELETE HOLDING - Remove a coin from user's portfolio
    func deleteHolding(userId: String, coinId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("holdings")
            .document(coinId)
            .delete()
    }
    
    // LOAD USER'S TRANSACTIONS - Get all buy/sell history
    func loadTransactions(userId: String) async throws -> [Transaction] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("transactions")
            .order(by: "date", descending: true) // Most recent first
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Transaction.self)
        }
    }
    
    // SAVE TRANSACTION - Record a buy or sell action
    func saveTransaction(userId: String, transaction: Transaction) async throws {
        try db.collection("users")
            .document(userId)
            .collection("transactions")
            .document(transaction.id.uuidString)
            .setData(from: transaction)
    }
    
    // ATOMIC SAVE - Save both transaction and holding atomically
    func saveTransactionAndHolding(userId: String, transaction: Transaction, holding: Holding) async throws {
        let batch = db.batch()
        
        // Add transaction to batch
        let transactionRef = db.collection("users")
            .document(userId)
            .collection("transactions")
            .document(transaction.id.uuidString)
        try batch.setData(from: transaction, forDocument: transactionRef)
        
        // Add holding to batch
        let holdingRef = db.collection("users")
            .document(userId)
            .collection("holdings")
            .document(holding.coinId)
        try batch.setData(from: holding, forDocument: holdingRef)
        
        // Execute all operations atomically
        try await batch.commit()
    }
    
    // DELETE ALL USER DATA - Clean up when user deletes account
    func deleteAllUserData(userId: String) async throws {
        let userDoc = db.collection("users").document(userId)
        
        // Delete all holdings
        let holdingsSnapshot = try await userDoc.collection("holdings").getDocuments()
        for document in holdingsSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete all transactions
        let transactionsSnapshot = try await userDoc.collection("transactions").getDocuments()
        for document in transactionsSnapshot.documents {
            try await document.reference.delete()
        }
        
        // Delete user document
        try await userDoc.delete()
    }
}

// FIRESTORE ERRORS - Custom errors for better error handling
enum FirestoreError: Error, LocalizedError {
    case userNotAuthenticated
    case documentNotFound
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .documentNotFound:
            return "Document not found"
        case .invalidData:
            return "Invalid data format"
        case .networkError:
            return "Network connection error"
        }
    }
}