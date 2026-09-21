//
//  AuthFormModel.swift
//  CryptoApp
//
//  State and logic for the login / registration form.
//

import Foundation
import Observation

@MainActor
@Observable
final class AuthFormModel {
    enum Mode {
        case login
        case register
    }

    var mode: Mode = .login
    var email = ""
    var password = ""
    private(set) var isSubmitting = false
    /// Shown under the form; cleared on the next attempt or when switching mode.
    private(set) var errorMessage: String?

    var isLogin: Bool {
        mode == .login
    }

    /// Firebase requires at least 6 characters for a new password.
    private static let minimumNewPasswordLength = 6

    var canSubmit: Bool {
        guard !isSubmitting, !trimmedEmail.isEmpty, !password.isEmpty else { return false }
        return isLogin || password.count >= Self.minimumNewPasswordLength
    }

    func toggleMode() {
        mode = isLogin ? .register : .login
        errorMessage = nil
    }

    func submit(using authService: AuthService) async {
        guard canSubmit else { return }

        isSubmitting = true
        defer { isSubmitting = false }
        errorMessage = nil

        do {
            switch mode {
            case .login:
                try await authService.login(email: trimmedEmail, password: password)
            case .register:
                try await authService.createUser(email: trimmedEmail, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
