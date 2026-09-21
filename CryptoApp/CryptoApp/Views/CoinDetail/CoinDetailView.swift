//
//  CoinDetailView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI
import Kingfisher

struct CoinDetailView: View {
    let coin: Coin
    let watchlistViewModel: any WatchlistViewModelProtocol
    let portfolioViewModel: any PortfolioViewModelProtocol
    private let coinService: CoinServiceProtocol
    
    @State private var viewModel: CoinDetailViewModel
    
    // MAIN CONSTRUCTOR - Requires ViewModels to ensure consistent state
    init(coin: Coin, 
         coinService: CoinServiceProtocol,
         portfolioViewModel: any PortfolioViewModelProtocol,
         watchlistViewModel: any WatchlistViewModelProtocol) {
        
        self.coin = coin
        self.coinService = coinService
        self.portfolioViewModel = portfolioViewModel
        self.watchlistViewModel = watchlistViewModel
        
        // Initialize CoinDetailViewModel with watchlist functionality
        self._viewModel = State(wrappedValue: CoinDetailViewModel(coin: coin, watchlistViewModel: watchlistViewModel))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.isLoadingFullData {
                    loadingIndicatorView
                }
                
                chartView
                overviewSectionView
                additionalDetailsSectionView
                marketStatisticsSectionView
                quickActionsSectionView
            }
        }
        .navigationTitle(viewModel.coin.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarContentView
            }
        }
        .task {
            // LOAD DATA - Ensure both ViewModels have loaded data
            await portfolioViewModel.loadPortfolioData()
            await watchlistViewModel.loadWatchlist()
        }
    }
    
    // MARK: - Computed Properties for Clean UI
    private var loadingIndicatorView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading market data...")
                .secondaryText()
        }
        .padding(.top, 8)
    }
    
    private var chartView: some View {
        CoinDetailChartView(coin: viewModel.coin)
            .padding(.vertical)
    }
    
    private var overviewSectionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Overview")
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Divider()
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "Current Price",
                    value: Decimal(viewModel.coin.currentPrice).asCurrencyString(),
                    footnote: Decimal(viewModel.coin.priceChangePercentage24H).asPercentageString()
                )
                InfoItemView(
                    title: "Market Capitalization",
                    value: Decimal(viewModel.coin.marketCap ?? 0).asAbbreviatedString(),
                    footnote: Decimal(viewModel.coin.marketCapChangePercentage24H ?? 0).asPercentageString()
                )
            }
            .padding(.horizontal, 15)
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "Rank",
                    value: "\(viewModel.coin.marketCapRank)",
                    footnote: nil
                )
                InfoItemView(
                    title: "Volume",
                    value: Decimal(viewModel.coin.totalVolume ?? 0).asAbbreviatedString(),
                    footnote: viewModel.volumeChangePercentage ?? "data not available"
                )
            }
            .padding(.horizontal, 15)
        }
    }
    
    private var additionalDetailsSectionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Additional Details")
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Divider()
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "ATH",
                    value: Decimal(viewModel.coin.ath ?? 0).asCurrencyString(),
                    footnote: viewModel.coin.athDate?.asFormattedDate
                )
                InfoItemView(
                    title: "ATL",
                    value: Decimal(viewModel.coin.atl ?? 0).asCurrencyString(),
                    footnote: viewModel.coin.atlDate?.asFormattedDate
                )
            }
            .padding(.horizontal, 15)
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "Circulating Supply",
                    value: Decimal(viewModel.coin.circulatingSupply ?? 0).asAbbreviatedString(),
                    footnote: viewModel.coin.symbol.uppercased()
                )
                InfoItemView(
                    title: "Max Supply",
                    value: viewModel.coin.maxSupply != nil ? Decimal(viewModel.coin.maxSupply!).asAbbreviatedString() : "No Limit",
                    footnote: viewModel.coin.maxSupply != nil ? viewModel.coin.symbol.uppercased() : nil
                )
            }
            .padding(.horizontal, 15)
        }
    }
    
    private var marketStatisticsSectionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Market Statistics")
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Divider()
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "24h High",
                    value: Decimal(viewModel.coin.high24H ?? 0).asCurrencyString(),
                    footnote: "Daily Peak"
                )
                InfoItemView(
                    title: "24h Low",
                    value: Decimal(viewModel.coin.low24H ?? 0).asCurrencyString(),
                    footnote: "Daily Low"
                )
            }
            .padding(.horizontal, 15)
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "Price Change",
                    value: Decimal(viewModel.coin.priceChange24H).asCurrencyString(),
                    footnote: Decimal(viewModel.coin.priceChangePercentage24H).asPercentageString()
                )
                InfoItemView(
                    title: "Market Cap Change",
                    value: Decimal(viewModel.coin.marketCapChange24H ?? 0).asAbbreviatedString(),
                    footnote: Decimal(viewModel.coin.marketCapChangePercentage24H ?? 0).asPercentageString()
                )
            }
            .padding(.horizontal, 15)
        }
    }
    
    private var quickActionsSectionView: some View {
        VStack(spacing: 20) {
            Text("Quick Actions")
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                TradingButton(type: .buy) {
                    viewModel.buyCoin()
                }
                .sheet(isPresented: $viewModel.showBuyModal) {
                    TradingModalView(coin: viewModel.coin, tradeType: .buy, portfolioViewModel: portfolioViewModel)
                }
                
                TradingButton(type: .sell) {
                    viewModel.sellCoin()
                }
                .sheet(isPresented: $viewModel.showSellModal) {
                    TradingModalView(coin: viewModel.coin, tradeType: .sell, portfolioViewModel: portfolioViewModel)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    private var toolbarContentView: some View {
        HStack(spacing: 8) {
            Button(action: {
                viewModel.toggleWatchlist()
            }) {
                Image(systemName: viewModel.isWatched ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(viewModel.isWatched ? .yellow : .gray)
            }
            
            Text(viewModel.coin.symbol.uppercased())
                .headlineText()
                .foregroundStyle(.secondary)
            KFImage(URL(string: viewModel.coin.image))
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        }
    }
}

#Preview {
    CoinDetailView(
        coin: Coin.sample,
        coinService: MockCoinService(),
        portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
        watchlistViewModel: WatchlistViewModel(authService: AuthService.shared)
    )
}