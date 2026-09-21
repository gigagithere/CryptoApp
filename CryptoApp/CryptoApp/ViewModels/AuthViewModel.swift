//
//  AuthViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 15/08/2025.
//

import FirebaseAuth
import SwiftUI
import Foundation

@MainActor
protocol AuthViewModelProtocol: Observable {
    var isAuthenticated: Bool { get }
    var currentUser: FirebaseAuth.User? { get }
    var error: AuthError? { get }
    var showError: Bool { get }
    var errorMessage: String { get }
    
    func login(email: String, password: String)
    func register(email: String, password: String)
}

@MainActor
@Observable
class AuthViewModel: AuthViewModelProtocol {
    var isAuthenticated = false
    var currentUser: FirebaseAuth.User?
    var error: AuthError? = nil
    var showError = false
    var errorMessage = ""
    private let authService: AuthService
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService.shared
    }

    func login(email: String, password: String) {
        Task {
            do {
                // Clear any previous errors
                clearError()
                
                // Delegate authentication to service layer
                try await authService.login(email: email, password: password)
                
                // ✅ Success: Update UI state
                currentUser = authService.userSession
                isAuthenticated = true
            } catch {
                // ❌ Handle authentication failure
                handleError(error)
            }
        }
    }

    ///   - password: New user's password
    func register(email: String, password: String) {
        Task {
            do {
                // Clear any previous errors
                clearError()
                
                // Delegate account creation to service layer
                try await authService.createUser(email: email, password: password)
                
                // ✅ Success: Update UI state (user is automatically logged in)
                currentUser = authService.userSession
                isAuthenticated = true
            } catch {
                // ❌ Handle registration failure
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        // Convert to typed error or default to unknown
        self.error = error as? AuthError ?? .unknown(error.localizedDescription)
        
        // Extract user-readable message
        self.errorMessage = error.localizedDescription
        
        // Trigger error alert presentation in UI
        self.showError = true
    }
    
    /// 🧹 Clear any existing error state
    /// Called before new authentication attempts
    private func clearError() {
        self.error = nil
        self.errorMessage = ""
        self.showError = false
    }
} 
