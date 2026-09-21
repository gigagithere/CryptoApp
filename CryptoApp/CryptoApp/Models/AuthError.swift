//
//  AuthError.swift
//  CryptoApp
//

import Foundation
import FirebaseAuth

nonisolated enum AuthError: Error, LocalizedError {
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

// Firebase reports errors as NSError codes; this turns them into our own messages.
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
