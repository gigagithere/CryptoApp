//
//  AuthButton.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 30/01/2025.
//

import SwiftUI

// MARK: - Button used on the login / registration screen

struct AuthButton: View {
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(.capsule)
        }
    }
}

#Preview {
    AuthButton(
        text: "Sign up",
        backgroundColor: Color.black.opacity(0.5),
        foregroundColor: .white,
        action: {
        }
    )
}
