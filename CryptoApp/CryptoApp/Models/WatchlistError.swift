//
//  WatchlistError.swift
//  CryptoApp
//

import Foundation

nonisolated enum WatchlistError: Error, LocalizedError {
    case userNotAuthenticated
    case coinAlreadyWatched
    case coinNotInWatchlist
    case firestoreSaveFailed
    case firestoreLoadFailed
    case networkError
    case invalidData
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return String(localized: "Please sign in to manage your watchlist")
        case .coinAlreadyWatched:
            return String(localized: "This coin is already in your watchlist")
        case .coinNotInWatchlist:
            return String(localized: "This coin is not in your watchlist")
        case .firestoreSaveFailed:
            return String(localized: "Failed to save watchlist data")
        case .firestoreLoadFailed:
            return String(localized: "Failed to load watchlist data")
        case .networkError:
            return String(localized: "Network error. Please check your connection")
        case .invalidData:
            return String(localized: "Invalid watchlist data format")
        case .unknown(let message):
            return String(localized: "Watchlist error: \(message)")
        }
    }
}
