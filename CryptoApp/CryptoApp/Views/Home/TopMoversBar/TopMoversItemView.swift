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
            KFImage(URL(string: coin.image))
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.orange)
            
            HStack {
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .bold()
                
                Text(Decimal(coin.currentPrice).asCurrencyString())
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
            
            Text(Decimal(coin.priceChangePercentage24H).asPercentageString())
                .font(.title2)
                .foregroundStyle(coin.priceChangePercentage24H > 0 ? .green : .red)
        }
        
        .frame(height: 120)
        .containerRelativeFrame(.horizontal, count: 2, spacing: 10)
        .background(.ultraThinMaterial.opacity(0.9))
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

