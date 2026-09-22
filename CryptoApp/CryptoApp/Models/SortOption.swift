//
//  SortOption.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import SwiftUI

// The raw values are stable identifiers (not shown on screen), so they stay in English;
// `title` below is what's actually displayed and it is what gets localized.
enum SortOption: String, CaseIterable {
    case marketCap = "Market Cap"
    case price = "Price"
    case change = "24h Change"
    case volume = "Volume"
    case watchlist = "Favorites"

    var title: LocalizedStringKey {
        switch self {
        case .marketCap: "Market Cap"
        case .price: "Price"
        case .change: "24h Change"
        case .volume: "Volume"
        case .watchlist: "Favorites"
        }
    }

    var iconName: String {
        switch self {
        case .marketCap: "chart.bar.fill"
        case .price: "dollarsign.circle"
        case .change: "percent"
        case .volume: "chart.line.uptrend.xyaxis"
        case .watchlist: "star.fill"
        }
    }

    /// Favorites are always shown by market cap, so there is no order to pick.
    var hasDirectionControl: Bool {
        self != .watchlist
    }

    var emptyStateIcon: String {
        self == .watchlist ? "star" : "magnifyingglass"
    }

    var emptyStateTitle: LocalizedStringKey {
        self == .watchlist ? "No Favorites Yet" : "No Coins Found"
    }

    var emptyStateMessage: LocalizedStringKey {
        self == .watchlist
            ? "Tap the star on any coin to add it to your favorites"
            : "Try adjusting your search or sort criteria"
    }

    /// The coins sorted by this option (for `.watchlist`: only the watched coins, by market cap).
    func sorted(_ coins: [Coin], order: SortOrder, watchedIDs: Set<String>) -> [Coin] {
        let ascending = hasDirectionControl && order == .ascending

        switch self {
        case .marketCap:
            return coins.sorted { ascending ? ($0.marketCap ?? 0) < ($1.marketCap ?? 0) : ($0.marketCap ?? 0) > ($1.marketCap ?? 0) }
        case .price:
            return coins.sorted { ascending ? $0.currentPrice < $1.currentPrice : $0.currentPrice > $1.currentPrice }
        case .change:
            return coins.sorted { ascending ? $0.priceChangePercentage24H < $1.priceChangePercentage24H : $0.priceChangePercentage24H > $1.priceChangePercentage24H }
        case .volume:
            return coins.sorted { ascending ? ($0.totalVolume ?? 0) < ($1.totalVolume ?? 0) : ($0.totalVolume ?? 0) > ($1.totalVolume ?? 0) }
        case .watchlist:
            return coins
                .filter { watchedIDs.contains($0.id) }
                .sorted { ($0.marketCap ?? 0) > ($1.marketCap ?? 0) }
        }
    }
}
