//
//  TopMoversView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct TopMoversView: View {
    @State private var topMoversVM: TopMoversViewModel
    private let coinService: CoinServiceProtocol
    private let portfolioViewModel: any PortfolioViewModelProtocol
    private let watchlistViewModel: any WatchlistViewModelProtocol
    
    init(coinService: CoinServiceProtocol, portfolioViewModel: any PortfolioViewModelProtocol, watchlistViewModel: any WatchlistViewModelProtocol) {
        self.coinService = coinService
        self.portfolioViewModel = portfolioViewModel
        self.watchlistViewModel = watchlistViewModel
        self._topMoversVM = State(initialValue: TopMoversViewModel(coinService: coinService))
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Top Movers")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(topMoversVM.topMovingCoins) { coin in
                        NavigationLink(destination: CoinDetailView(coin: coin, coinService: coinService, portfolioViewModel: portfolioViewModel, watchlistViewModel: watchlistViewModel)){
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
    TopMoversView(
        coinService: MockCoinService(), 
        portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
        watchlistViewModel: WatchlistViewModel(authService: AuthService.shared)
    )
}
