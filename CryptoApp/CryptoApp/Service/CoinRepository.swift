//
//  CoinRepository.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import Foundation

protocol CoinRepositoryProtocol {
    func fetchCoins() async throws -> [Coin]
}

final class CoinRepository: CoinRepositoryProtocol {
    private let baseUrl = "https://api.coingecko.com/api/v3/coins/"
    
    private var marketURL: URL? {
        URL(string: "\(baseUrl)markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=true&price_change_percentage=24h")
    }
    
    func fetchCoins() async throws -> [Coin] {
        guard let url = marketURL else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Coin].self, from: data)
    }
}
