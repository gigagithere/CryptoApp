//
//  CoinImage.swift
//  CryptoApp
//

import SwiftUI
import Kingfisher

/// A coin logo loaded from its URL; shows the first letter of the symbol until it arrives.
/// The size grows with the user's text size.
struct CoinImage: View {
    let url: String
    let symbol: String
    @ScaledMetric private var size: CGFloat

    init(url: String, symbol: String, size: CGFloat = 28) {
        self.url = url
        self.symbol = symbol
        _size = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    var body: some View {
        KFImage(URL(string: url))
            .placeholder {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .overlay {
                        Text(symbol.prefix(1).uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                    }
            }
            .retry(maxCount: 3, interval: .seconds(2))
            .fade(duration: 0.25)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#Preview {
    CoinImage(url: Coin.sample.image, symbol: "BTC")
}
