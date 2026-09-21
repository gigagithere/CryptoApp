//
//  TopMoversItemView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct TopMoversItemView: View {
    let coin: Coin
    
    var body: some View {
        VStack(alignment: .leading) {
            CoinImage(url: coin.image, symbol: coin.symbol, size: 32)
            
            HStack {
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .bold()
                
                Text(coin.currentPrice, format: .usd)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Text(coin.priceChangePercentage24H / 100, format: .percentChange)
                .font(.title2)
                .foregroundStyle(coin.priceChangePercentage24H > 0 ? .green : .red)
        }
        .frame(height: 120)
        .containerRelativeFrame(.horizontal, count: 2, spacing: 10)
        .background(.ultraThinMaterial.opacity(0.9))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray3), lineWidth: 2)
        }
        .scrollTransition(.animated, axis: .horizontal) { content, phase in
            content
                .opacity(phase.isIdentity ? 1.0 : 0.6)
                .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
        }
    }
}

#Preview {
    TopMoversItemView(coin: Coin.sample)
}
