//
//  ViewStyles.swift
//  CryptoApp
//
//  Created by Claude on 28/08/2025.
//

import SwiftUI

extension View {
    func cardStyle() -> some View {
        padding()
            .background(.ultraThinMaterial)
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
