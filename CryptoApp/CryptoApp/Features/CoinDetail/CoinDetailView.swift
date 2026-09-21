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
                PriceHeaderView(coin: coin)
                CoinDetailChartView(coin: coin)
                    .padding(.vertical)
                InfoSectionView(title: "Overview", items: coin.overviewItems)
                InfoSectionView(title: "Additional Details", items: coin.additionalItems)
                InfoSectionView(title: "Market Statistics", items: coin.marketStatisticItems)
            }
            .padding(.bottom, Spacing.xl)
        }
        // Buy and Sell stay in reach while scrolling, so the tab bar makes room for them on this screen
        .safeAreaInset(edge: .bottom) {
            QuickActionsView { tradeType = $0 }
                .sensoryFeedback(.impact(weight: .medium), trigger: tradeType) { _, new in new != nil }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .refreshable {
            try? await coinService.forceRefresh()
        }
        .navigationTitle(coin.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: Spacing.s) {
                    WatchlistButton(coinID: coin.id, font: .title3)
                    Text(coin.symbol.uppercased())
                        .headlineText()
                        .foregroundStyle(.secondary)
                    CoinImage(url: coin.image, symbol: coin.symbol, size: 25)
                }
            }
        }
        .sheet(item: $tradeType) { type in
            TradingModalView(coinID: coin.id, type: type,
                             maxQuantity: type == .sell ? portfolio.getTotalHolding(for: coin.id) : nil)
        }
    }
}

#Preview {
    NavigationStack {
        CoinDetailView(coinID: Coin.sample.id)
    }
    .previewEnvironment()
}
