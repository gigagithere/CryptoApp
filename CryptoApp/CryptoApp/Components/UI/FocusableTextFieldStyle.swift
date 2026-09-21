//
//  FocusableTextFieldStyle.swift
//  CryptoApp
//
//  📝⭐⭐⭐ FOCUSABLE TEXT FIELD STYLE ⭐⭐⭐
//  Custom TextField style that changes appearance based on focus state
//  Adapts colors for focused/unfocused states with smooth transitions
//
//  Created by Bartosz Mrugała on 06/08/2025.
//

import SwiftUI

// MARK: - Focusable Text Field Style

/// 📝 Custom TextField style with focus-aware styling
/// Changes foreground and background colors based on focus state
struct FocusableTextFieldStyle: TextFieldStyle {
    @FocusState private var isFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .focused($isFocused)
            .foregroundStyle(isFocused ? Color.primary : Color.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isFocused ? Color(.systemBackground) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.accentColor : Color(.systemGray4), lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

