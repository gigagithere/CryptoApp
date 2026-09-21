//
//  PortfolioError.swift
//  CryptoApp
//

import Foundation

nonisolated enum PortfolioError: Error, LocalizedError, Equatable {
    case userNotAuthenticated
    case invalidQuantity
    case insufficientHoldings
    case coinNotFound
    case firestoreSaveFailed
    case firestoreLoadFailed
    case invalidData
    case networkError
    case holdingNotFound
    case transactionFailed
    case priceUnavailable
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Please sign in to manage your portfolio"
        case .invalidQuantity:
            return "Please enter a valid quantity"
        case .insufficientHoldings:
            return "You don't have enough coins to sell"
        case .coinNotFound:
            return "Coin not found in your portfolio"
        case .firestoreSaveFailed:
            return "Failed to save portfolio data"
        case .firestoreLoadFailed:
            return "Failed to load portfolio data"
        case .invalidData:
            return "Invalid portfolio data format"
        case .networkError:
            return "Network error. Please check your connection"
        case .holdingNotFound:
            return "Holding not found in portfolio"
        case .transactionFailed:
            return "Transaction failed. Please try again"
        case .priceUnavailable:
            return "The current price isn't available. Pull to refresh and try again"
        case .unknown(let message):
            return "Portfolio error: \(message)"
        }
    }
}
