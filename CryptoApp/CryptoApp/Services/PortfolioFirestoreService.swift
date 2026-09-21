//
//  PortfolioFirestoreService.swift
//  CryptoApp
//
//  Created by Claude on 16/08/2025.
//

import Foundation
@preconcurrency import FirebaseFirestore // Firestore is thread-safe but not yet annotated Sendable
import os

// PROTOCOL - Defines what portfolio storage operations are available
nonisolated protocol PortfolioFirestoreServiceProtocol: Sendable {
    @concurrent
    func loadHoldings(userId: String) async throws -> [Holding]
    @concurrent
    func loadTransactions(userId: String) async throws -> [Transaction]
    /// Records a trade and updates the holding in ONE atomic write.
    /// A holding with zero quantity is deleted (that's how selling everything works).
    func commitTrade(userId: String, transaction: Transaction, holding: Holding) async throws
}

// PORTFOLIO FIRESTORE SERVICE - Handles all portfolio data operations with Firestore
nonisolated final class PortfolioFirestoreService: PortfolioFirestoreServiceProtocol {
    private let db = Firestore.firestore()
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CryptoApp", category: "PortfolioFirestore")

    // LOAD USER'S HOLDINGS - Get all coins the user owns
    func loadHoldings(userId: String) async throws -> [Holding] {
        let snapshot = try await userDocument(userId)
            .collection("holdings")
            .getDocuments()

        return decode(Holding.self, from: snapshot.documents)
    }

    // LOAD USER'S TRANSACTIONS - Get all buy/sell history
    func loadTransactions(userId: String) async throws -> [Transaction] {
        let snapshot = try await userDocument(userId)
            .collection("transactions")
            .order(by: "date", descending: true) // Most recent first
            .getDocuments()

        return decode(Transaction.self, from: snapshot.documents)
    }

    // COMMIT TRADE - Save the transaction and the resulting holding atomically
    @concurrent
    func commitTrade(userId: String, transaction: Transaction, holding: Holding) async throws {
        let user = userDocument(userId)
        let batch = db.batch()

        let transactionRef = user.collection("transactions").document(transaction.id.uuidString)
        try batch.setData(from: transaction, forDocument: transactionRef)

        let holdingRef = user.collection("holdings").document(holding.coinId)
        if holding.quantity > 0 {
            try batch.setData(from: holding, forDocument: holdingRef)
        } else {
            batch.deleteDocument(holdingRef)
        }

        try await batch.commit()
    }

    // MARK: - Private

    private func userDocument(_ userId: String) -> DocumentReference {
        db.collection("users").document(userId)
    }

    /// Decodes documents, logging (instead of silently dropping) the ones that can't be read.
    private func decode<T: Decodable>(_ type: T.Type, from documents: [QueryDocumentSnapshot]) -> [T] {
        documents.compactMap { document in
            do {
                return try document.data(as: T.self)
            } catch {
                Self.logger.error("Skipping undecodable \(String(describing: T.self), privacy: .public) document \(document.documentID, privacy: .public): \(error.localizedDescription, privacy: .public)")
                return nil
            }
        }
    }
}
