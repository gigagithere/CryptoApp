//
//  AuthView.swift
//  CryptoApp
//
//  Unified authentication view for both login and registration
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var model = AuthFormModel()
    @State private var floatOffset: CGFloat = 0
    @State private var rotationAngle: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Header Section
            VStack(alignment: .leading) {
                Text(model.isLogin ? "Log In" : "Register")
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
                
                Text(model.isLogin ? "Please log in to continue" : "Create your account")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                
                authForm
                actionButtons
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: model.mode)
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
                text: $model.email,
                keyboardType: .emailAddress,
                contentType: .emailAddress
            )
            .submitLabel(.next)
            
            CustomTextField(
                icon: "lock",
                placeholder: "Password",
                text: $model.password,
                isSecure: true,
                contentType: model.isLogin ? .password : .newPassword
            )
            .submitLabel(.go)
            .onSubmit(submit)
            
            if let message = model.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 20) {
            // Primary Action Button
            Login_RegisterButton(
                text: model.isLogin ? "Log in" : "Sign Up",
                backgroundColor: .customDarkBlue,
                foregroundColor: .white,
                action: submit
            )
            .disabled(!model.canSubmit)
            .opacity(model.canSubmit || model.isSubmitting ? 1 : 0.5)
            .overlay {
                if model.isSubmitting {
                    ProgressView()
                        .tint(.white)
                }
            }
            
            DividerView()
            
            // Secondary Action Button
            Login_RegisterButton(
                text: model.isLogin ? "Sign Up" : "Back to login",
                backgroundColor: .customDarkBlue.opacity(0.8),
                foregroundColor: .white,
                action: toggleAuthMode
            )
        }
    }
    
    // MARK: - Actions
    
    private func submit() {
        Task { await model.submit() }
    }
    
    private func toggleAuthMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            model.toggleMode()
        }
    }
}

#Preview {
    AuthView()
}
