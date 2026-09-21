//
//  TopMoversItemView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct TopMoversItemView: View {
    let coin: Coin
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        // Symbol and price sit side by side normally, stacked at accessibility text sizes
        let layout = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading))
                                                         : AnyLayout(HStackLayout())
        
        VStack(alignment: .leading) {
            CoinImage(url: coin.image, symbol: coin.symbol, size: 32)
            
            layout {
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .bold()
                
                Text(coin.currentPrice, format: .usd)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            
            Text(coin.priceChangePercentage24H / 100, format: .percentChangeSigned)
                .font(.title2)
                .foregroundStyle(coin.priceChangePercentage24H > 0 ? .green : .red)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading) // grows with the text size
        .containerRelativeFrame(.horizontal, count: 2, spacing: 10)
        .card()
        .overlay {
            RoundedRectangle(cornerRadius: Radius.medium)
                .strokeBorder(.separator)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(coin.symbol.uppercased()), \(coin.currentPrice.formatted(.usd))")
        .accessibilityValue((coin.priceChangePercentage24H / 100).formatted(.percentChangeSigned))
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
