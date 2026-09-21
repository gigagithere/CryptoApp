//
//  SingleRowView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//

import SwiftUI

/// One coin in the market list: the favorite star, then a link to the coin's screen.
struct SingleRowView: View {
    let coin: Coin
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private var isUp: Bool {
        coin.priceChangePercentage24H >= 0
    }
    
    var body: some View {
        // Name and price sit side by side normally, and stacked when the text is so large they'd squeeze each other
        let isLargeText = dynamicTypeSize.isAccessibilitySize
        let layout = isLargeText ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.xs))
                                 : AnyLayout(HStackLayout())
        
        HStack(spacing: 0) {
            WatchlistButton(coinID: coin.id, font: .caption)
            
            NavigationLink(value: Route.coin(id: coin.id)) {
                HStack(spacing: Spacing.m) {
                    Text(coin.marketCapRank, format: .number)
                        .secondaryText()
                        .frame(minWidth: 20, alignment: .leading)
                    
                    CoinImage(url: coin.image, symbol: coin.symbol)
                    
                    layout {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(coin.name)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Text(coin.symbol.uppercased())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if !isLargeText {
                            Spacer()
                        }
                        
                        VStack(alignment: isLargeText ? .leading : .trailing, spacing: 2) {
                            Text(coin.currentPrice, format: .usd)
                                .font(.subheadline)
                            
                            // The sign backs up the color for people who can't tell green from red
                            HStack(spacing: 3) {
                                Image(systemName: isUp ? "plus" : "minus")
                                    .font(.caption2)
                                
                                Text(abs(coin.priceChangePercentage24H) / 100, format: .percentChange)
                                    .font(.caption)
                            }
                            .foregroundStyle(isUp ? .green : .red)
                        }
                    }
                }
                .contentShape(.rect)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(coin.name), \(coin.symbol.uppercased()), rank \(coin.marketCapRank)")
                .accessibilityValue("\(coin.currentPrice.formatted(.usd)), \(isUp ? "up" : "down") \((abs(coin.priceChangePercentage24H) / 100).formatted(.percentChange)) in 24 hours")
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Spacing.xs)
        // The star's tap target is 44 pt wide but its icon only about 15 pt and centred in it: pull the row
        // left so the icon lines up with the screen margin (title, search field) instead of floating inward
        .padding(.leading, -Spacing.l)
    }
}

#Preview {
    NavigationStack {
        SingleRowView(coin: Coin.sample)
            .routeDestinations()
    }
    .previewEnvironment()
}
