//
//  ViewStyles.swift
//  CryptoApp
//
//  Created by Claude on 28/08/2025.
//

import SwiftUI

extension View {
    /// A frosted card: material background, rounded corners and, optionally, a soft shadow.
    /// Add your own padding first.
    func card(radius: CGFloat = Radius.medium, elevated: Bool = false) -> some View {
        background(.ultraThinMaterial, in: .rect(cornerRadius: radius))
            .shadow(color: elevated ? .black.opacity(0.1) : .clear, radius: 4, y: 2)
    }

    func secondaryText() -> some View {
        font(.caption)
            .foregroundStyle(.secondary)
    }

    func headerText() -> some View {
        font(.title2)
            .fontWeight(.semibold)
    }

    func headlineText() -> some View {
        font(.headline)
            .fontWeight(.semibold)
    }
}
