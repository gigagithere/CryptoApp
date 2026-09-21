//
//  CoinList.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//

import SwiftUI

struct CoinList: View {
    let homeVM: HomeViewModel
    let watchlistViewModel: any WatchlistViewModelProtocol
    let portfolioViewModel: any PortfolioViewModelProtocol
    let coinService: CoinServiceProtocol
    
    @State private var selectedSortOption: SortOption = .marketCap
    @State private var sortOrder: SortOrder = .descending
    
    // MARK: - Sorted Coins
    private var sortedCoins: [Coin] {
        SortOption.sort(homeVM.filteredCoins, 
                       by: selectedSortOption, 
                       order: sortOrder, 
                       watchlistViewModel: watchlistViewModel)
    }
    
//     MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            coinHeaderView
            if sortedCoins.isEmpty {
                emptyStateView
            } else {
                coinListView
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
                                sortOrder = option.defaultOrder
                                HapticFeedback.impact(.light)
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
                                    HapticFeedback.impact(.light)
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
    
    private var coinListView: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(sortedCoins) { coin in
                    NavigationLink(destination: CoinDetailView(coin: coin, coinService: coinService, portfolioViewModel: portfolioViewModel, watchlistViewModel: watchlistViewModel)) {
                        SingleRowView(coin: coin, watchlistViewModel: watchlistViewModel)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .safeAreaPadding(.bottom)
        }
    }
    
    
    
    struct StatusDotGlowView: View {
        @State private var animate = false
        
        var body: some View {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
                .scaleEffect(animate ? 1.2 : 1.0)
                .opacity(animate ? 0.7 : 1.0)
                .blur(radius: animate ? 0.8 : 0.2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        animate = true
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        CoinList(
            homeVM: HomeViewModel(coinService: MockCoinService()), 
            watchlistViewModel: WatchlistViewModel(authService: AuthService.shared),
            portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
            coinService: MockCoinService()
        )
    }
}

