//
//  AuthService.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import SwiftUI
import FirebaseAuth

@MainActor
@Observable
class AuthService {
    
    var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()

    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    // LOGIN - Authenticate user and update state
    func login(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
        }
        catch {
            throw AuthError.from(firebaseError: error)
        }
    }

    // REGISTER - Create new user account and update state
    func createUser(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
        }
        catch {
            throw AuthError.from(firebaseError: error)
        }
    }

    // LOGOUT - Sign out user and clear all cached data
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        }
        catch {
            throw AuthError.signOutFailed
        }
    }
}
