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
        .frame(width: 150, height: 150)
        .background(.itemBg)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray3), lineWidth: 2)
        )
    }
}

//#Preview {
//    TopMoversItemView()
//}

