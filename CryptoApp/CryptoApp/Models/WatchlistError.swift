//
//  WatchlistError.swift
//  CryptoApp
//

import Foundation

enum WatchlistError: Error, LocalizedError {
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
            return "Please sign in to manage your watchlist"
        case .coinAlreadyWatched:
            return "This coin is already in your watchlist"
        case .coinNotInWatchlist:
            return "This coin is not in your watchlist"
        case .firestoreSaveFailed:
            return "Failed to save watchlist data"
        case .firestoreLoadFailed:
            return "Failed to load watchlist data"
        case .networkError:
            return "Network error. Please check your connection"
        case .invalidData:
            return "Invalid watchlist data format"
        case .unknown(let message):
            return "Watchlist error: \(message)"
        }
    }
}
