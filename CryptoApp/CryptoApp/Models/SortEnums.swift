//
//  SortEnums.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import Foundation

enum SortOption: String, CaseIterable {
    case marketCap = "Market Cap"
    case price = "Price"
    case change = "24h Change"
    case volume = "Volume"
    case watchlist = "Favorites"
    
    var iconName: String {
        switch self {
        case .marketCap:
            return "chart.bar.fill"
        case .price:
            return "dollarsign.circle"
        case .change:
            return "percent"
        case .volume:
            return "chart.line.uptrend.xyaxis"
        case .watchlist:
            return "star.fill"
        }
    }
    
    var hasDirectionControl: Bool {
        switch self {
        case .marketCap, .price, .change, .volume:
            return true
        case .watchlist:
            return false
        }
    }
    
    var defaultOrder: SortOrder {
        switch self {
        case .marketCap, .price, .change, .volume:
            return .descending
        case .watchlist:
            return .descending
        }
    }
}

enum SortOrder: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
}

// MARK: - Sorting Logic Extension
extension SortOption {
    /// Sorts an array of coins based on the selected sort option and order
    /// - Parameters:
    ///   - coins: Array of coins to sort
    ///   - order: Sort order (ascending/descending)
    ///   - watchlistViewModel: ViewModel for watchlist filtering (required for .watchlist option)
    /// - Returns: Sorted array of coins
    @MainActor
    static func sort(_ coins: [Coin], 
                    by option: SortOption, 
                    order: SortOrder, 
                    watchlistViewModel: (any WatchlistViewModelProtocol)?) -> [Coin] {
        var result = coins
        
        // Use default order for sorts that don't have direction control
        let effectiveOrder = option.hasDirectionControl ? order : option.defaultOrder
        
        switch option {
        case .marketCap:
            result.sort { effectiveOrder == .ascending ? 
                ($0.marketCap ?? 0) < ($1.marketCap ?? 0) : 
                ($0.marketCap ?? 0) > ($1.marketCap ?? 0) }
            
        case .price:
            result.sort { effectiveOrder == .ascending ? 
                $0.currentPrice < $1.currentPrice : 
                $0.currentPrice > $1.currentPrice }
            
        case .change:
            result.sort { effectiveOrder == .ascending ? 
                $0.priceChangePercentage24H < $1.priceChangePercentage24H : 
                $0.priceChangePercentage24H > $1.priceChangePercentage24H }
            
        case .volume:
            result.sort { effectiveOrder == .ascending ? 
                ($0.totalVolume ?? 0) < ($1.totalVolume ?? 0) : 
                ($0.totalVolume ?? 0) > ($1.totalVolume ?? 0) }
            
        case .watchlist:
            // Filter to show only watched coins, then sort by market cap desc
            result = result.filter { watchlistViewModel?.isWatched($0.id) ?? false }
            result.sort { ($0.marketCap ?? 0) > ($1.marketCap ?? 0) }
        }
        
        return result
    }
    
    // MARK: - UI Properties
    var counterLabel: String {
        switch self {
        case .watchlist:
            return "Favorites"
        default:
            return "Total Coins"
        }
    }
    
    var emptyStateIcon: String {
        switch self {
        case .watchlist:
            return "star"
        default:
            return "magnifyingglass"
        }
    }
    
    var emptyStateTitle: String {
        switch self {
        case .watchlist:
            return "No Favorites Yet"
        default:
            return "No Coins Found"
        }
    }
    
    var emptyStateMessage: String {
        switch self {
        case .watchlist:
            return "Tap the star on any coin to add it to your favorites"
        default:
            return "Try adjusting your search or sort criteria"
        }
    }
}
