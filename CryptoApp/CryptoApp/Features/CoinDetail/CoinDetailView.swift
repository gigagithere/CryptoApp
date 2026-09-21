//
//  CoinDetailView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI

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
                CoinDetailChartView(coin: coin)
                    .padding(.vertical)
                InfoSectionView(title: "Overview", items: coin.overviewItems)
                InfoSectionView(title: "Additional Details", items: coin.additionalItems)
                InfoSectionView(title: "Market Statistics", items: coin.marketStatisticItems)
                QuickActionsView { tradeType = $0 }
                    .sensoryFeedback(.impact(weight: .medium), trigger: tradeType) { _, new in new != nil }
            }
        }
        .refreshable {
            try? await coinService.forceRefresh()
        }
        .navigationTitle(coin.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    WatchlistButton(coinID: coin.id, font: .title3)
                    Text(coin.symbol.uppercased())
                        .headlineText()
                        .foregroundStyle(.secondary)
                    CoinImage(url: coin.image, symbol: coin.symbol, size: 25)
                }
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
}

#Preview {
    NavigationStack {
        CoinDetailView(coinID: Coin.sample.id)
    }
    .previewEnvironment()
}
