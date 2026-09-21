//
//  AuthService.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import SwiftUI
import FirebaseAuth

@Observable
final class AuthService {

    private(set) var userSession: FirebaseAuth.User?

    /// UI tests can't log in to Firebase: they start the app with this fixed id standing in for the signed-in user.
    private let uiTestUserID: String?

    /// The id of the signed-in user, or nil when signed out.
    var userID: String? {
        userSession?.uid ?? uiTestUserID
    }

    /// What Profile shows: the display name, else the email.
    var accountName: String {
        if let name = userSession?.displayName, !name.isEmpty {
            return name
        }
        return userSession?.email ?? (uiTestUserID != nil ? "Test User" : "User")
    }

    @ObservationIgnored private var authStateHandle: AuthStateDidChangeListenerHandle?

    init(uiTestUserID: String? = nil) {
        self.uiTestUserID = uiTestUserID
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
