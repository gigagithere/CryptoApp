//
//  Login:RegisterButton.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 30/01/2025.
//

import SwiftUI

struct Login_RegisterButton: View {
    let text: String
    let backgroundColor: Color?
    let foregroundColor: Color?
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
            
            .foregroundColor(foregroundColor)
            .clipShape(.capsule)
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.2), lineWidth: 2)
            )
        }
    }
}

#Preview {
    Login_RegisterButton(
        text: "Sign up",
        backgroundColor: Color.black.opacity(0.5),
        foregroundColor: .white,
        action: {
        }
    )
}
