//
//  AuthView.swift
//  CryptoApp
//
//  Unified authentication view for both login and registration
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var isLogin = true
    @State private var loginViewModel = LoginViewModel()
    @State private var registrationViewModel = RegistrationViewModel()
    @State private var floatOffset: CGFloat = 0
    @State private var rotationAngle: CGFloat = 0
    
    private var currentEmail: Binding<String> {
        isLogin ? $loginViewModel.email : $registrationViewModel.email
    }
    
    private var currentPassword: Binding<String> {
        isLogin ? $loginViewModel.password : $registrationViewModel.password
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header Section
            VStack(alignment: .leading) {
                Text(isLogin ? "Log In" : "Register")
                    .font(.largeTitle)
                    .bold()
                
                Text("Your journey into the world of crypto starts here!")
                    .headlineText()
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Main Content
            VStack(alignment: .center, spacing: 20) {
                // Animated Logo
                animatedLogo
                
                Text(isLogin ? "Please log in to continue" : "Create your account")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                authForm
                actionButtons
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: isLogin)
    }
    
    // MARK: - Components
    
    private var animatedLogo: some View {
        Image("logo")
            .resizable()
            .scaledToFit()
            .cornerRadius(40)
            .frame(width: 180, height: 180)
            .shadow(color: .gray, radius: 10, x: 7, y: 10)
            .offset(y: floatOffset)
            .rotationEffect(.degrees(rotationAngle))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.7)) {
                    rotationAngle += 360
                }
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                ) {
                    floatOffset = -10
                }
            }
    }
    
    private var authForm: some View {
        VStack(spacing: 20) {
            CustomTextField(
                icon: "envelope",
                placeholder: "Email",
                text: currentEmail
            )
            
            CustomTextField(
                icon: "lock",
                placeholder: "Password",
                text: currentPassword
            )
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 20) {
            // Primary Action Button
            Login_RegisterButton(
                text: isLogin ? "Log in" : "Sign Up",
                backgroundColor: .customDarkBlue,
                foregroundColor: .white,
                action: primaryAction
            )
            
            DividerView()
            
            // Secondary Action Button
            Login_RegisterButton(
                text: isLogin ? "Sign Up" : "Back to login",
                backgroundColor: .customDarkBlue.opacity(0.8),
                foregroundColor: .white,
                action: toggleAuthMode
            )
        }
    }
    
    // MARK: - Actions
    
    private func primaryAction() {
        Task {
            if isLogin {
                try await loginViewModel.loginUser()
            } else {
                try? await registrationViewModel.registerUser()
            }
        }
    }
    
    private func toggleAuthMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isLogin.toggle()
        }
    }
}

#Preview {
    AuthView()
}
