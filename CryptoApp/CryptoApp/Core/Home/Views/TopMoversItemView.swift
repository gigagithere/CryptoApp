//
//  TopMoversItemView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI
import Kingfisher

struct TopMoversItemView: View {
    let coin: Coin
    
    var body: some View {
        VStack(alignment: .leading) {
            // image
            KFImage(URL(string: coin.image))
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.orange)
            
            // coin info
            HStack {
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .bold()
                
                Text(coin.currentPrice.toCurrency())
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
            
            // coin percent change
            Text(coin.priceChangePercentage24H.toPercentString())
                .font(.title2)
                .foregroundStyle(coin.priceChangePercentage24H > 0 ? .green : .red)
        }
        
        .frame(height: 150)
        .containerRelativeFrame(.horizontal, count: 2, spacing: 20)
        .background(.itemBg)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray3), lineWidth: 2)
        )
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

