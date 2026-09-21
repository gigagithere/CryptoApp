//
//  MarketStatusView.swift
//  CryptoApp
//

import SwiftUI

/// Says how fresh the prices on screen really are.
struct MarketStatusView: View {
    @Environment(CoinService.self) private var coinService

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.xs) {
            Text("Market Status")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                if coinService.isShowingCachedData {
                    StatusDotGlowView(color: .orange, pulsing: false)
                    Text("Saved prices")
                        .foregroundStyle(.orange)
                } else if coinService.lastError != nil {
                    StatusDotGlowView(color: .orange, pulsing: false)
                    Text("Couldn't update")
                        .foregroundStyle(.orange)
                } else if let lastUpdated = coinService.lastUpdated {
                    StatusDotGlowView()
                    Text("Updated \(lastUpdated, style: .relative) ago")
                        .foregroundStyle(.green)
                } else {
                    StatusDotGlowView(color: .gray, pulsing: false)
                    Text("Updating…")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.footnote.weight(.semibold))
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    MarketStatusView()
        .previewEnvironment()
}
