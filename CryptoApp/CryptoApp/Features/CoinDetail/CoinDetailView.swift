//
//  CoinDetailView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI
import Kingfisher

struct CoinDetailView: View {
    let coinID: String
    
    @Environment(CoinService.self) private var coinService
    @Environment(PortfolioViewModel.self) private var portfolio
    @Environment(WatchlistViewModel.self) private var watchlist
    @State private var tradeType: TransactionType?
    
    var body: some View {
        // Always the live coin: a refresh while this screen is open updates it
        if let coin = coinService.coin(id: coinID) {
            content(for: coin)
        } else {
            ContentUnavailableView("Coin not found", systemImage: "questionmark.circle")
        }
    }
    
    private func content(for coin: Coin) -> some View {
        ScrollView {
            VStack {
                chartView(coin)
                overviewSectionView(coin)
                additionalDetailsSectionView(coin)
                marketStatisticsSectionView(coin)
                quickActionsSectionView
            }
        }
        .navigationTitle(coin.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarContentView(coin)
            }
        }
        .sheet(item: $tradeType) { type in
            TradingModalView(coinID: coin.id, type: type)
        }
        .task {
            // LOAD DATA - Ensure both ViewModels have loaded data
            await portfolio.loadPortfolioData()
            await watchlist.loadWatchlist()
        }
    }
    
    // MARK: - Computed Properties for Clean UI
    private func chartView(_ coin: Coin) -> some View {
        CoinDetailChartView(coin: coin)
            .padding(.vertical)
    }
    
    private func overviewSectionView(_ coin: Coin) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Overview")
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Divider()
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "Current Price",
                    value: Decimal(coin.currentPrice).asCurrencyString(),
                    footnote: Decimal(coin.priceChangePercentage24H).asPercentageString()
                )
                InfoItemView(
                    title: "Market Capitalization",
                    value: Decimal(coin.marketCap ?? 0).asAbbreviatedString(),
                    footnote: Decimal(coin.marketCapChangePercentage24H ?? 0).asPercentageString()
                )
            }
            .padding(.horizontal, 15)
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "Rank",
                    value: "\(coin.marketCapRank)",
                    footnote: nil
                )
                InfoItemView(
                    title: "Volume",
                    value: Decimal(coin.totalVolume ?? 0).asAbbreviatedString(),
                    footnote: "data not available"
                )
            }
            .padding(.horizontal, 15)
        }
    }
    
    private func additionalDetailsSectionView(_ coin: Coin) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Additional Details")
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Divider()
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "ATH",
                    value: Decimal(coin.ath ?? 0).asCurrencyString(),
                    footnote: coin.athDate?.asFormattedDate
                )
                InfoItemView(
                    title: "ATL",
                    value: Decimal(coin.atl ?? 0).asCurrencyString(),
                    footnote: coin.atlDate?.asFormattedDate
                )
            }
            .padding(.horizontal, 15)
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "Circulating Supply",
                    value: Decimal(coin.circulatingSupply ?? 0).asAbbreviatedString(),
                    footnote: coin.symbol.uppercased()
                )
                InfoItemView(
                    title: "Max Supply",
                    value: coin.maxSupply != nil ? Decimal(coin.maxSupply!).asAbbreviatedString() : "No Limit",
                    footnote: coin.maxSupply != nil ? coin.symbol.uppercased() : nil
                )
            }
            .padding(.horizontal, 15)
        }
    }
    
    private func marketStatisticsSectionView(_ coin: Coin) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Market Statistics")
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Divider()
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "24h High",
                    value: Decimal(coin.high24H ?? 0).asCurrencyString(),
                    footnote: "Daily Peak"
                )
                InfoItemView(
                    title: "24h Low",
                    value: Decimal(coin.low24H ?? 0).asCurrencyString(),
                    footnote: "Daily Low"
                )
            }
            .padding(.horizontal, 15)
            
            HStack(spacing: 15) {
                InfoItemView(
                    title: "Price Change",
                    value: Decimal(coin.priceChange24H).asCurrencyString(),
                    footnote: Decimal(coin.priceChangePercentage24H).asPercentageString()
                )
                InfoItemView(
                    title: "Market Cap Change",
                    value: Decimal(coin.marketCapChange24H ?? 0).asAbbreviatedString(),
                    footnote: Decimal(coin.marketCapChangePercentage24H ?? 0).asPercentageString()
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
                    tradeType = .buy
                }
                
                TradingButton(type: .sell) {
                    tradeType = .sell
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: tradeType) { _, new in new != nil }
            .padding(.horizontal)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    private func toolbarContentView(_ coin: Coin) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                Task { await watchlist.toggleWatchlist(for: coin.id) }
            }) {
                Image(systemName: watchlist.isWatched(coin.id) ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(watchlist.isWatched(coin.id) ? .yellow : .gray)
            }
            .sensoryFeedback(.impact(weight: .light), trigger: watchlist.isWatched(coin.id))
            
            Text(coin.symbol.uppercased())
                .headlineText()
                .foregroundStyle(.secondary)
            KFImage(URL(string: coin.image))
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        }
    }
}

#Preview {
    NavigationStack {
        CoinDetailView(coinID: Coin.sample.id)
    }
    .previewEnvironment()
}
