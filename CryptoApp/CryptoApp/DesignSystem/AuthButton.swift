//
//  AuthButton.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 30/01/2025.
//

import SwiftUI

// MARK: - Button used on the login / registration screen

struct AuthButton: View {
    let text: LocalizedStringKey
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(tint)
    }
}

#Preview {
    AuthButton(text: "Sign up", tint: .customDarkBlue) { }
        .padding()
}
