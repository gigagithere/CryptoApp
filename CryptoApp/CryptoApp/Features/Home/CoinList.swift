//
//  CoinList.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//

import SwiftUI

struct CoinList: View {
    let searchText: String
    
    @Environment(CoinService.self) private var coinService
    @Environment(WatchlistViewModel.self) private var watchlist
    @State private var sortOption: SortOption = .marketCap
    @State private var sortOrder: SortOrder = .descending
    
    /// Search first, then sort. Called once per body pass.
    private var visibleCoins: [Coin] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let matching = query.isEmpty ? coinService.coins : coinService.coins.filter {
            $0.name.localizedStandardContains(query) || $0.symbol.localizedStandardContains(query)
        }
        return sortOption.sorted(matching, order: sortOrder, watchedIDs: watchlist.watchedCoinIds)
    }
    
    var body: some View {
        let coins = visibleCoins
        
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cryptocurrencies")
                    .font(.title2)
                    .bold()
                
                HStack {
                    SortMenu(option: $sortOption, order: $sortOrder)
                    Spacer()
                    MarketStatusView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
            
            if coins.isEmpty {
                ContentUnavailableView {
                    Label(sortOption.emptyStateTitle, systemImage: sortOption.emptyStateIcon)
                } description: {
                    Text(sortOption.emptyStateMessage)
                }
                .padding(.top, 50)
            } else {
                LazyVStack(spacing: 4) {
                    ForEach(coins) { coin in
                        NavigationLink(value: Route.coin(id: coin.id)) {
                            SingleRowView(coin: coin)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .safeAreaPadding(.bottom)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            CoinList(searchText: "")
        }
        .routeDestinations()
    }
    .previewEnvironment()
}
