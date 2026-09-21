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
        Group {
            if !coinService.coins.isEmpty {
                ScrollView {
                    VStack {
                        if coinService.isShowingCachedData {
                            StatusBanner(systemImage: "icloud.slash", tint: .orange,
                                         message: Text("Showing saved prices. Pull down to refresh."))
                                .padding(.horizontal)
                        }
                        
                        TopMoversView()
                            .padding()
                        
                        Divider()
                        
                        CoinList(searchText: searchText)
                    }
                }
                .refreshable {
                    try? await coinService.forceRefresh() // an error is shown by MarketStatusView
                }
            } else if let error = coinService.lastError {
                ContentUnavailableView {
                    Label("Couldn't Load Prices", systemImage: "wifi.slash")
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("Try Again") {
                        Task { try? await coinService.forceRefresh() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ProgressView("Loading prices…")
                    .controlSize(.large)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Coins")
        .navigationTitle("Live Prices")
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .routeDestinations()
    }
    .previewEnvironment()
}
