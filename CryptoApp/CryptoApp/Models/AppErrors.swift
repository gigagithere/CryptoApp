//
//  AppErrors.swift
//  CryptoApp
//
//  Created by Claude on 16/08/2025.
//

import Foundation
import FirebaseAuth

// MARK: - Authentication Errors
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case invalidEmail
    case tooManyRequests
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case userNotAuthenticated
    case signOutFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .tooManyRequests:
            return "Too many attempts. Please try again later"
        case .userNotFound:
            return "No account found with this email"
        case .emailAlreadyInUse:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password should be at least 6 characters"
        case .networkError:
            return "Network connection error. Please try again"
        case .userNotAuthenticated:
            return "Please sign in to continue"
        case .signOutFailed:
            return "Failed to sign out. Please try again"
        case .unknown(let message):
            return "Authentication error: \(message)"
        }
    }
}

// MARK: - Portfolio Errors
enum PortfolioError: Error, LocalizedError, Equatable {
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

// MARK: - Watchlist Errors
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

// MARK: - Error Conversion Helpers
extension AuthError {
    static func from(firebaseError: Error) -> AuthError {
        let nsError = firebaseError as NSError
        guard nsError.domain == AuthErrors.domain,
              let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(firebaseError.localizedDescription)
        }
        
        switch code {
        case .invalidCredential, .wrongPassword: // Firebase reports a wrong password as invalidCredential
            return .invalidCredentials
        case .invalidEmail:
            return .invalidEmail
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        case .tooManyRequests:
            return .tooManyRequests
        default:
            return .unknown(firebaseError.localizedDescription)
        }
    }
}
