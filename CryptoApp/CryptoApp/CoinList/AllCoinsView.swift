//
//  AllCoinsView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct AllCoinsView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("All Coins")
                .font(.headline)
                .padding()
            
            HStack {
                Text("Coin")
                
                Spacer()
                
                Text("Prices")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)
            
            ScrollView {
                VStack {
                    ForEach(viewModel.coins) { coin in
                        NavigationLink(destination: CoinDetailView(coin: coin)){
                            CoinRowView(coin: coin)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    }
                }
            }
        .onAppear {
            Task {
                await viewModel.fetchData() // Pobranie danych po załadowaniu widoku
            }
        }
    }
}

#Preview {
    AllCoinsView(viewModel: HomeViewModel())
}
