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
final class AuthService {

    private(set) var userSession: FirebaseAuth.User?

    @ObservationIgnored private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        self.userSession = Auth.auth().currentUser

        // Keeps the UI in sync with Firebase: sign-in on another screen, an expired
        // session or a deleted account all end up here, not only our own login/logout calls.
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.userSession = user
            }
        }
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

    // LOGOUT - Sign out user
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        }
        catch {
            throw AuthError.signOutFailed
        }
    }
}
