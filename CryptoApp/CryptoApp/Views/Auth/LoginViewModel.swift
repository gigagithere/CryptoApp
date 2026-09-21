//
//  LoginViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//


import Observation

// MARK: - LoginViewModel

@Observable
class LoginViewModel {
    var email = ""
    var password = ""
    
    func loginUser() async throws {
        try await AuthService.shared.login(email: email, password: password)
    }
}
