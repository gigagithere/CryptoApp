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
            return String(localized: "Please sign in to manage your portfolio")
        case .invalidQuantity:
            return String(localized: "Please enter a valid quantity")
        case .insufficientHoldings:
            return String(localized: "You don't have enough coins to sell")
        case .coinNotFound:
            return String(localized: "Coin not found in your portfolio")
        case .firestoreSaveFailed:
            return String(localized: "Failed to save portfolio data")
        case .firestoreLoadFailed:
            return String(localized: "Failed to load portfolio data")
        case .invalidData:
            return String(localized: "Invalid portfolio data format")
        case .networkError:
            return String(localized: "Network error. Please check your connection")
        case .holdingNotFound:
            return String(localized: "Holding not found in portfolio")
        case .transactionFailed:
            return String(localized: "Transaction failed. Please try again")
        case .priceUnavailable:
            return String(localized: "The current price isn't available. Pull to refresh and try again")
        case .unknown(let message):
            return String(localized: "Portfolio error: \(message)")
        }
    }
}
