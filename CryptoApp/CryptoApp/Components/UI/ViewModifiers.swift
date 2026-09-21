//
//  ViewModifiers.swift
//  CryptoApp
//
//  Created by Claude on 28/08/2025.
//

import SwiftUI

// MARK: - Card Styling
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
    }
}

// MARK: - Text Styling
struct SecondaryTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

struct HeaderTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.semibold)
    }
}

struct HeadlineTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.semibold)
    }
}

// MARK: - Button Styling
struct TradingButtonModifier: ViewModifier {
    let backgroundColor: Color
    let isDisabled: Bool
    
    init(backgroundColor: Color, isDisabled: Bool = false) {
        self.backgroundColor = backgroundColor
        self.isDisabled = isDisabled
    }
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isDisabled ? .gray : backgroundColor)
    }
}

// MARK: - Container Styling
struct InfoContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
    }
}

// MARK: - Convenience Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func secondaryText() -> some View {
        modifier(SecondaryTextModifier())
    }
    
    func headerText() -> some View {
        modifier(HeaderTextModifier())
    }
    
    func headlineText() -> some View {
        modifier(HeadlineTextModifier())
    }
    
    func tradingButtonStyle(backgroundColor: Color, isDisabled: Bool = false) -> some View {
        modifier(TradingButtonModifier(backgroundColor: backgroundColor, isDisabled: isDisabled))
    }
    
    func infoContainer() -> some View {
        modifier(InfoContainerModifier())
    }
}