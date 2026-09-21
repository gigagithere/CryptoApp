//
//  WatchlistFirestoreService.swift
//  CryptoApp
//
//  Created by Claude on 16/08/2025.
//

import Foundation
import FirebaseFirestore

// Model
struct Watchlist: Codable, Identifiable {
    let id: String // coinId
    let coinId: String
    let dateAdded: Date
    
    init(coinId: String, dateAdded: Date = Date()) {
        self.id = coinId
        self.coinId = coinId
        self.dateAdded = dateAdded
    }
}

// PROTOCOL
protocol WatchlistFirestoreServiceProtocol {
    func loadWatchedCoins(userId: String) async throws -> Set<String>
    func addToWatchlist(userId: String, coinId: String) async throws
    func removeFromWatchlist(userId: String, coinId: String) async throws
    func isWatched(userId: String, coinId: String) async throws -> Bool
    func clearWatchlist(userId: String) async throws
}

// WATCHLIST FIRESTORE SERVICE - Handles all watchlist/favorites data operations
class WatchlistFirestoreService: WatchlistFirestoreServiceProtocol {
    private let db = Firestore.firestore()
    
    // LOAD WATCHED COINS - Get user's favorite coins list
    func loadWatchedCoins(userId: String) async throws -> Set<String> {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("watchlist")
            .getDocuments()
        
        let coinIds = snapshot.documents.compactMap { document in
            try? document.data(as: Watchlist.self)
        }.map { $0.coinId }
        
        return Set(coinIds)
    }
    
    // ADD TO WATCHLIST - Add a coin to user's favorites
    func addToWatchlist(userId: String, coinId: String) async throws {
        let watchlist = Watchlist(coinId: coinId)
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("watchlist")
            .document(coinId)
        
        try await docRef.setData(from: watchlist)
    }
    
    // REMOVE FROM WATCHLIST - Remove a coin from user's favorites
    func removeFromWatchlist(userId: String, coinId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("watchlist")
            .document(coinId)
            .delete()
    }
    
    // CHECK IF WATCHED - See if a coin is in user's favorites
    func isWatched(userId: String, coinId: String) async throws -> Bool {
        let document = try await db.collection("users")
            .document(userId)
            .collection("watchlist")
            .document(coinId)
            .getDocument()
        
        return document.exists
    }
    
    // CLEAR WATCHLIST - Remove all favorite coins
    func clearWatchlist(userId: String) async throws {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("watchlist")
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
}
