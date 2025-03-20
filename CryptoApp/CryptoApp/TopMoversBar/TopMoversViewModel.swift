//
//  TopMoversViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import Foundation

@MainActor
final class TopMoversViewModel: ObservableObject {
    @Published var topMovingCoins: [Coin] = []
    
    func updateTopMovers(from coins: [Coin]) {
        let sorted = coins.sorted { $0.priceChangePercentage24H > $1.priceChangePercentage24H }
        topMovingCoins = Array(sorted.prefix(10))
    }
}
