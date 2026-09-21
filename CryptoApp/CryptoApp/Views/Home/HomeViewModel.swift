//
//  HomeViewModel.swift
//  CryptoApp
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var searchText: String = "" {
        didSet {
            updateFilteredCoins() 
        }
    }
    
    private(set) var filteredCoins: [Coin] = []
    private let coinService: CoinServiceProtocol
    
    init(coinService: CoinServiceProtocol) {
        self.coinService = coinService
        updateFilteredCoins()
    }
    
    func refreshFilteredCoins() {
        updateFilteredCoins()
    }
    
    private func updateFilteredCoins() {
        if searchText.isEmpty {
            filteredCoins = coinService.coins
        } else {
            filteredCoins = coinService.coins.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.symbol.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
