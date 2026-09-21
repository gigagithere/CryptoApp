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
    @State private var selectedSortOption: SortOption = .marketCap
    @State private var sortOrder: SortOrder = .descending
    
    // MARK: - Visible Coins
    /// Search first, then sort. Called once per body pass.
    private var visibleCoins: [Coin] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let matching = query.isEmpty ? coinService.coins : coinService.coins.filter {
            $0.name.localizedStandardContains(query) || $0.symbol.localizedStandardContains(query)
        }
        return selectedSortOption.sorted(matching, order: sortOrder, watchedIDs: watchlist.watchedCoinIds)
    }
    
//     MARK: - View
    var body: some View {
        let coins = visibleCoins
        
        VStack(alignment: .leading, spacing: 0) {
            coinHeaderView
            if coins.isEmpty {
                emptyStateView
            } else {
                coinListView(coins)
            }
        }
    }
    
    // MARK: - Computed Properties for Clean UI
    private var coinHeaderView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cryptocurrencies")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Combined Summary and Sort Controls
            HStack(spacing: 16) {
                // Compact Sort Menu (moved to left)
                Menu {
                    Section("Sort By") {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                selectedSortOption = option
                                // Auto-set the best sort order for this option
                                sortOrder = .descending
                            } label: {
                                Label(option.rawValue, systemImage: option.iconName)
                            }
                        }
                    }
                    
                    if selectedSortOption.hasDirectionControl {
                        Section("Order") {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Button {
                                    sortOrder = order
                                } label: {
                                    Label(order.rawValue,
                                          systemImage: order == .ascending ? "arrow.up" : "arrow.down")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: selectedSortOption.iconName)
                            .font(.subheadline)
                        Text("Sort")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: selectedSortOption)
                .sensoryFeedback(.selection, trigger: sortOrder)
                
                Spacer()
                
                // Market Status
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Market Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 6) {
                        StatusDotGlowView()
                        Text("Live")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedSortOption.emptyStateIcon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(selectedSortOption.emptyStateTitle)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(selectedSortOption.emptyStateMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
    }
    
    private func coinListView(_ coins: [Coin]) -> some View {
        LazyVStack(spacing: 4) {
            ForEach(coins) { coin in
                NavigationLink(destination: CoinDetailView(coinID: coin.id)) {
                    SingleRowView(coin: coin)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .safeAreaPadding(.bottom)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            CoinList(searchText: "")
        }
    }
    .previewEnvironment()
}
