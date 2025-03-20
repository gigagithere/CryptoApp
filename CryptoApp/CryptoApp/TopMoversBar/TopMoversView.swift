//
//  TopMoversView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct TopMoversView: View {
    @ObservedObject var topMoversVM: TopMoversViewModel
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Top Movers")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(topMoversVM.topMovingCoins) { coin in
                        NavigationLink(destination: CoinDetailView(coin: coin)){
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
    TopMoversView(topMoversVM: TopMoversViewModel())
}
