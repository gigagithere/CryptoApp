//
//  CurrentHoldingsPage.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI
import Kingfisher


struct CurrentHoldingsPage: View {
    let holdings: [Holding]
    private var portfolioViewModel: any PortfolioViewModelProtocol
    private let coinService: CoinServiceProtocol
    private var watchlistViewModel: any WatchlistViewModelProtocol
    
    init(holdings: [Holding], portfolioViewModel: any PortfolioViewModelProtocol, coinService: CoinServiceProtocol, watchlistViewModel: any WatchlistViewModelProtocol) {
        self.holdings = holdings
        self.portfolioViewModel = portfolioViewModel
        self.coinService = coinService
        self.watchlistViewModel = watchlistViewModel
    }

    private var totalPortfolioValue: Decimal {
        portfolioViewModel.totalPortfolioValue()
    }
    
   
    var body: some View {
        VStack {
            if holdings.isEmpty {
                emptyStateView
            } else {
                portfolioSummaryView
                holdingsListView
            }
        }
        .navigationTitle("Current Holdings")
        .navigationBarTitleDisplayMode(.large)
    }
    
    
    // MARK: - Computed Properties for Clean UI
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bitcoinsign.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Holdings Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start trading to build your portfolio")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var portfolioSummaryView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Holdings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(holdings.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Portfolio Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(totalPortfolioValue.asCurrencyString())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
    
    private var holdingsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(holdings) { holding in
                    CurrentHoldingsRowView(
                        holding: holding,
                        currentPrice: portfolioViewModel.getCurrentPrice(for: holding.coinId) ?? holding.averagePurchasePrice,
                        portfolioViewModel: portfolioViewModel,
                        coinService: coinService,
                        watchlistViewModel: watchlistViewModel
                    )
                }
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.bottom)
        }
    }
    
}

#Preview {
    NavigationStack {
        CurrentHoldingsPage(
            holdings: [
                Holding(
                    coinId: "bitcoin",
                    coinSymbol: "BTC",
                    quantity: 0.25,
                    purchasePrice: 42000,
                    date: Date().addingTimeInterval(-86400 * 10),
                    imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
                ),
                Holding(
                    coinId: "ethereum",
                    coinSymbol: "ETH",
                    quantity: 1.5,
                    purchasePrice: 2800,
                    date: Date().addingTimeInterval(-86400 * 7),
                    imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"
                ),
                Holding(
                    coinId: "solana",
                    coinSymbol: "SOL",
                    quantity: 10,
                    purchasePrice: 95,
                    date: Date().addingTimeInterval(-86400 * 3),
                    imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png"
                )
            ],
            portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
            coinService: MockCoinService(),
            watchlistViewModel: WatchlistViewModel(authService: AuthService.shared)
        )
    }
}
