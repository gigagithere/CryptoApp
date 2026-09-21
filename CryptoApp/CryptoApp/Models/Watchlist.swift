//
//  Watchlist.swift
//  CryptoApp
//

import Foundation

/// One favorite coin, stored as a document in the user's `watchlist` collection.
nonisolated struct Watchlist: Codable, Identifiable {
    let id: String // coinId
    let coinId: String
    let dateAdded: Date

    init(coinId: String, dateAdded: Date = .now) {
        self.id = coinId
        self.coinId = coinId
        self.dateAdded = dateAdded
    }
}
