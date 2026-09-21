//
//  RegistrationViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//


import Observation

// MARK: - RegistrationViewModel

@Observable
class RegistrationViewModel {
    var email = ""
    var password = ""
    
    func registerUser() async throws {
        try await AuthService.shared.createUser(email: email, password: password)
    }
}
