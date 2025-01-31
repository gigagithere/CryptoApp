//
//  CustomTextFieldStyle.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 30/01/2025.
//

import SwiftUI

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .scaleEffect(isFocused || !text.isEmpty ? 0.8 : 1.0)
                    .animation(.smooth(duration: 0.3), value: isFocused || !text.isEmpty)
                    .foregroundStyle(isFocused || !text.isEmpty ? .gray : .black)
                
                TextField(placeholder, text: $text, onEditingChanged: { editing in
                    withAnimation {
                        isFocused = editing
                    }
                })
                .font(.system(size: 16, weight: .regular))
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 5)
    }
}
