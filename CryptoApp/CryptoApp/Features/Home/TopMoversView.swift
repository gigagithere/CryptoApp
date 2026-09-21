//
//  TopMoversView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct TopMoversView: View {
    @Environment(CoinService.self) private var coinService
    
    /// The 10 coins with the biggest 24h gain
    private var topMovers: [Coin] {
        Array(coinService.coins.sorted { $0.priceChangePercentage24H > $1.priceChangePercentage24H }.prefix(10))
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Top Movers")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(topMovers) { coin in
                        NavigationLink(destination: CoinDetailView(coinID: coin.id)){
                            TopMoversItemView(coin: coin)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
            }
            .frame(height: 150)
            .scrollTargetLayout()
            .contentMargins(.horizontal, 35, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    NavigationStack {
        TopMoversView()
    }
    .previewEnvironment()
}
