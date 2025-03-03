//
//  RegistrationViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//

import Foundation
import SwiftUI



class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func loginUser() async throws {
        try await AuthService.shared.login(email: email, password: password)
    }
}
