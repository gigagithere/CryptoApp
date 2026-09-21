//
//  PriceHeaderView.swift
//  CryptoApp
//

import SwiftUI

/// The current price and the last 24 hours' change, right under the coin's name.
struct PriceHeaderView: View {
    let coin: Coin

    private var isUp: Bool {
        coin.priceChange24H >= 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(coin.currentPrice, format: .usd)
                .font(.largeTitle.bold())

            HStack(spacing: Spacing.xs) {
                // The arrow and the sign back up the color
                Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                Text("\(coin.priceChange24H, format: .usdChange) (\(coin.priceChangePercentage24H / 100, format: .percentChangeSigned))")
                Text("24h")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .foregroundStyle(isUp ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PriceHeaderView(coin: .sample)
}
