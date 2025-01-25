//
//  ProfileView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 12/12/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = "" // Pole na email
    @State private var password: String = "" // Pole na hasło
    @State private var isLoggedIn: Bool = false // Status logowania
    @State private var showError: Bool = false // Obsługa błędów logowania

    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn {
                    // Ekran profilu po zalogowaniu
                    VStack {
                        Text("Welcome to your profile!")
                            .font(.title)
                            .padding()

                        Button(action: {
                            isLoggedIn = false // Wylogowanie
                        }) {
                            Text("Log Out")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    // Formularz logowania
                    VStack(spacing: 20) {
                        Text("Log In")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 20)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if showError {
                            Text("Invalid email or password")
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                        Button(action: handleLogin) {
                            Text("Log In")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        NavigationLink(destination: RegistrationView()) {
                            Text("Don't have an account? Register here.")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
    
    // Obsługa logowania (do rozbudowy o Firebase)
    private func handleLogin() {
        // Przykładowa logika (do zastąpienia Firebase Auth)
        if email.lowercased() == "test@test.com" && password == "password" {
            isLoggedIn = true
            showError = false
        } else {
            showError = true
        }
    }
}


    


#Preview {
    LoginView()
}
