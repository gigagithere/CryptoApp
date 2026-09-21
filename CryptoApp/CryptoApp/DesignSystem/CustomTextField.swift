//
//  CustomTextField.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 30/01/2025.
//

import SwiftUI

/// A text field with a leading icon. It takes part in a form's focus chain:
/// pass the form's `@FocusState` and the value that stands for this field.
struct CustomTextField<Field: Hashable>: View {
    let icon: String
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var focus: FocusState<Field?>.Binding
    let field: Field
    /// Masks the input (passwords). Uses `SecureField`, so AutoFill and password managers work.
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil

    private var isFocused: Bool {
        focus.wrappedValue == field
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .scaleEffect(isFocused || !text.isEmpty ? 0.8 : 1.0)
                .animation(.smooth(duration: 0.3), value: isFocused || !text.isEmpty)
                .foregroundStyle(isFocused || !text.isEmpty ? .primary : .secondary)
                .accessibilityHidden(true)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .focused(focus, equals: field)
            .keyboardType(keyboardType)
            .textContentType(contentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding()
        .frame(minHeight: 44)
        .background(.fill.quaternary, in: .rect(cornerRadius: Radius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.medium)
                .strokeBorder(isFocused ? Color.accentColor : Color.clear)
        }
    }
}

private struct CustomTextFieldPreview: View {
    enum Field { case email, password }
    @FocusState private var focus: Field?

    var body: some View {
        VStack {
            CustomTextField(icon: "envelope", placeholder: "Email", text: .constant("test@example.com"), focus: $focus, field: .email)
            CustomTextField(icon: "lock", placeholder: "Password", text: .constant("secret"), focus: $focus, field: .password, isSecure: true)
        }
        .padding()
    }
}

#Preview {
    CustomTextFieldPreview()
}
