//
//  RegistrationViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//

import Foundation
import SwiftUI
import Firebase


class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func registerUser() async throws {
        try await AuthService.shared.createUser(email: email, password: password)
    }
}
