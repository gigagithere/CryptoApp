//
//  WatchlistFirestoreService.swift
//  CryptoApp
//
//  Created by Claude on 16/08/2025.
//

import Foundation
import FirebaseFirestore
import os

// PROTOCOL
protocol WatchlistFirestoreServiceProtocol {
    func loadWatchedCoins(userId: String) async throws -> Set<String>
    func addToWatchlist(userId: String, coinId: String) async throws
    func removeFromWatchlist(userId: String, coinId: String) async throws
}

// WATCHLIST FIRESTORE SERVICE - Handles all watchlist/favorites data operations
final class WatchlistFirestoreService: WatchlistFirestoreServiceProtocol {
    private let db = Firestore.firestore()
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CryptoApp", category: "WatchlistFirestore")
    
    // LOAD WATCHED COINS - Get user's favorite coins list
    func loadWatchedCoins(userId: String) async throws -> Set<String> {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("watchlist")
            .getDocuments()
        
        let coinIds = snapshot.documents.compactMap { document -> String? in
            do {
                return try document.data(as: Watchlist.self).coinId
            } catch {
                Self.logger.error("Skipping undecodable watchlist document \(document.documentID, privacy: .public): \(error.localizedDescription, privacy: .public)")
                return nil
            }
        }
        
        return Set(coinIds)
    }
    
    // ADD TO WATCHLIST - Add a coin to user's favorites
    func addToWatchlist(userId: String, coinId: String) async throws {
        let watchlist = Watchlist(coinId: coinId)
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("watchlist")
            .document(coinId)
        
        try docRef.setData(from: watchlist)
    }
    
    // REMOVE FROM WATCHLIST - Remove a coin from user's favorites
    func removeFromWatchlist(userId: String, coinId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("watchlist")
            .document(coinId)
            .delete()
    }
}
