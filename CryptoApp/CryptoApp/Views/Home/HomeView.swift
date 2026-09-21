//
//  HomeView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct HomeView: View {
    @State private var homeVM: HomeViewModel
    private var watchlistViewModel: any WatchlistViewModelProtocol
    private var portfolioViewModel: any PortfolioViewModelProtocol
    private let coinService: CoinServiceProtocol
    
    init(coinService: CoinServiceProtocol, portfolioViewModel: any PortfolioViewModelProtocol, watchlistViewModel: any WatchlistViewModelProtocol) {
        self.coinService = coinService
        self.portfolioViewModel = portfolioViewModel
        self.watchlistViewModel = watchlistViewModel
        self._homeVM = State(initialValue: HomeViewModel(coinService: coinService))
    }
    
    var body: some View {
        ScrollView {
                VStack {
                    TopMoversView(coinService: coinService, portfolioViewModel: portfolioViewModel, watchlistViewModel: watchlistViewModel)
                        .frame(height: 150)
                        .padding()
                    
                    Divider()
                    
                    CustomTextField(icon: "magnifyingglass", placeholder: "Search Coins", text: $homeVM.searchText)
                        .padding(10)
                        
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

                    CoinList(homeVM: homeVM, watchlistViewModel: watchlistViewModel, portfolioViewModel: portfolioViewModel, coinService: coinService)
                }
            }
            .refreshable {
                do {
                    try await coinService.forceRefresh()
                } catch {
                    // Error is already stored in coinService.lastError
                }
            }
        .navigationTitle("Live Prices")
        .onChange(of: coinService.coins) { _, _ in
            homeVM.refreshFilteredCoins()
        }
    }
}

#Preview {
    HomeView(
        coinService: MockCoinService(),
        portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
        watchlistViewModel: WatchlistViewModel(authService: AuthService.shared)
    )
}
