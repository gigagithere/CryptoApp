//
//  HomeView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct HomeView: View {
    @Environment(CoinService.self) private var coinService
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack {
                TopMoversView()
                    .frame(height: 150)
                    .padding()
                
                Divider()
                
                if coinService.coins.isEmpty, coinService.lastError != nil {
                    VStack(spacing: 12) {
                        Text("Couldn't load coins")
                            .font(.headline)
                        Button("Try again") {
                            Task { try? await coinService.forceRefresh() }
                        }
                    }
                    .padding()
                }

                CoinList(searchText: searchText)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Coins")
        .refreshable {
            try? await coinService.forceRefresh() // an error is already stored in coinService.lastError
        }
        .navigationTitle("Live Prices")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .previewEnvironment()
}
