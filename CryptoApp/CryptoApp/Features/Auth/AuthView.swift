//
//  AuthView.swift
//  CryptoApp
//
//  Unified authentication view for both login and registration
//

import SwiftUI

struct AuthView: View {
    @Environment(AuthService.self) private var authService
    @State private var model = AuthFormModel()
    
    private enum Field {
        case email, password
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            VStack(alignment: .leading) {
                Text(model.isLogin ? "Log In" : "Register")
                    .font(.largeTitle)
                    .bold()
                
                Text("Your journey into the world of crypto starts here!")
                    .headlineText()
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .center, spacing: Spacing.xl) {
                AnimatedLogo()
                
                Text(model.isLogin ? "Please log in to continue" : "Create your account")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.top, 10)
                
                VStack(spacing: Spacing.xl) {
                    CustomTextField(
                        icon: "envelope",
                        placeholder: "Email",
                        text: $model.email,
                        focus: $focusedField,
                        field: .email,
                        keyboardType: .emailAddress,
                        contentType: .emailAddress
                    )
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Password",
                        text: $model.password,
                        focus: $focusedField,
                        field: .password,
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
                
                VStack(spacing: Spacing.xl) {
                    AuthButton(
                        text: model.isLogin ? "Log in" : "Sign Up",
                        tint: .customDarkBlue,
                        action: submit
                    )
                    .accessibilityInputLabels(["Log in", "Sign up", "Submit"])
                    .disabled(!model.canSubmit)
                    .opacity(model.canSubmit || model.isSubmitting ? 1 : 0.5)
                    .overlay {
                        if model.isSubmitting {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    
                    DividerView()
                    
                    AuthButton(
                        text: model.isLogin ? "Sign Up" : "Back to login",
                        tint: .customDarkBlue.opacity(0.8),
                        action: toggleAuthMode
                    )
                }
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: model.mode)
    }
    
    private func submit() {
        Task { await model.submit(using: authService) }
    }
    
    private func toggleAuthMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            model.toggleMode()
        }
    }
}

#Preview {
    AuthView()
        .previewEnvironment()
}
