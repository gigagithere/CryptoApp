//
//  SingleRowView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//

import SwiftUI

/// One coin in the market list.
struct SingleRowView: View {
    let coin: Coin
    
    private var isUp: Bool {
        coin.priceChangePercentage24H >= 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            WatchlistButton(coinID: coin.id, font: .caption)
                .frame(width: 28, height: 28)
                .padding(.trailing, 13)
            
            Text(coin.marketCapRank, format: .number)
                .secondaryText()
                .fontWeight(.medium)
                .frame(width: 20, alignment: .leading)
            
            CoinImage(url: coin.image, symbol: coin.symbol)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.currentPrice, format: .usd)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 3) {
                    Image(systemName: isUp ? "plus" : "minus")
                        .font(.caption2)
                    
                    Text(abs(coin.priceChangePercentage24H) / 100, format: .percentChange)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(isUp ? .green : .red)
            }
        }
        .padding(.vertical, 12)
        .contentShape(.rect)
    }
}

#Preview {
    SingleRowView(coin: Coin.sample)
        .previewEnvironment()
}
