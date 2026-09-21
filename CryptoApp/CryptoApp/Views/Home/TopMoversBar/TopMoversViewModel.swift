//
//  TopMoversViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class TopMoversViewModel {
    private let coinService: CoinServiceProtocol
    
    init(coinService: CoinServiceProtocol) {
        self.coinService = coinService
    }
    
    var topMovingCoins: [Coin] {
        let sorted = coinService.coins.sorted { $0.priceChangePercentage24H > $1.priceChangePercentage24H }
        return Array(sorted.prefix(10))
    }
}
