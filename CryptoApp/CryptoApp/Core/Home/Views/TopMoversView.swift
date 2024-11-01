//
//  TopMoversView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct TopMoversView: View {
    @ObservedObject var viewModel: HomeViewModel
    var body: some View {
        VStack(alignment: .leading){
            Text("Top Movers")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(viewModel.topMovingCoins) { coin in
                        TopMoversItemView(coin: coin)
                            
                    }
                }
                .scrollTargetLayout()
                
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(25, for: .scrollContent)
        }
    }
}

#Preview {
    TopMoversView(viewModel: HomeViewModel())
}
