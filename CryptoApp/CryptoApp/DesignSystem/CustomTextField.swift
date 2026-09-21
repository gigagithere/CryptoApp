//
//  CustomTextFieldStyle.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 30/01/2025.
//

import SwiftUI

// MARK: - CustomTextField

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    /// Masks the input (passwords). Uses `SecureField`, so AutoFill and password managers work.
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .scaleEffect(isFocused || !text.isEmpty ? 0.8 : 1.0)
                    .animation(.smooth(duration: 0.3), value: isFocused || !text.isEmpty)
                    .foregroundStyle(isFocused || !text.isEmpty ? .primary : .secondary)

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .focused($isFocused)
                .font(.body)
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
            .padding()
            .frame(minHeight: 40)
            .background(
                RoundedRectangle(cornerRadius: Radius.medium)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.medium)
                            .fill(Color(.secondarySystemBackground))
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    VStack {
        CustomTextField(icon: "magnifyingglass", placeholder: "Search Text", text: .constant("Test"))
        CustomTextField(icon: "lock", placeholder: "Password", text: .constant("secret"), isSecure: true)
    }
    .padding()
}
