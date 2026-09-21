//
//  CoinDetailViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class CoinDetailViewModel {
    var coin: Coin
    var showBuyModal = false
    var showSellModal = false
    var isWatched = false
    var isLoadingFullData = false

    private let watchlistViewModel: (any WatchlistViewModelProtocol)?
    
    var hasFullData: Bool {
        return coin.marketCap != nil && coin.priceChangePercentage24H != 0
    }

    init(coin: Coin, watchlistViewModel: (any WatchlistViewModelProtocol)?) {
        self.coin = coin
        self.watchlistViewModel = watchlistViewModel
        self.isWatched = watchlistViewModel?.isWatched(coin.id) ?? false
    }
    
    // Update coin data from external source - loose coupling
    func updateCoin(_ updatedCoin: Coin) {
        coin = updatedCoin
    }
    
    func setLoading(_ loading: Bool) {
        isLoadingFullData = loading
    }

    func toggleWatchlist() {
        HapticFeedback.impact(.light)
        Task {
            await watchlistViewModel?.toggleWatchlist(for: coin.id)
            isWatched = watchlistViewModel?.isWatched(coin.id) ?? false
        }
    }

    func buyCoin() {
        HapticFeedback.impact(.medium)
        showBuyModal = true
    }

    func sellCoin() {
        HapticFeedback.impact(.medium)
        showSellModal = true
    }

    // Remove fetchFullDataIfNeeded - this will be handled by the View
    // CoinDetailViewModel is now pure business logic

    var volumeChangePercentage: String? {
        return nil
    }
}
