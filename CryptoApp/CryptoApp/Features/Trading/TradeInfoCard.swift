//
//  TradeInfoCard.swift
//  CryptoApp
//

import SwiftUI

/// A titled card on the trade sheet: price per coin, your holdings, the total.
struct TradeInfoCard<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: Spacing.s) {
            Text(title)
                .headlineText()
                .foregroundStyle(.secondary)
            content
        }
        .frame(maxWidth: .infinity)
        .padding()
        .card(radius: Radius.large)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TradeInfoCard(title: "Total Value") {
        Text(1234.5, format: .usd)
            .font(.title)
            .bold()
    }
    .padding()
}
