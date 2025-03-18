//
//  CoinDetailView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 31/01/2025.
//

import SwiftUI
import Kingfisher

struct CoinDetailView: View {
    let coin: Coin
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ChartView(coin: coin)
                        .padding(.vertical)
                }
            }
            .navigationTitle(coin.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack{
                        Text(coin.symbol.uppercased())
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        KFImage(URL(string: coin.image))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
        }
            }
        }
    }
}
#Preview {
    CoinDetailView(coin: Coin.sample)
}
