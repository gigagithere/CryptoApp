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
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "cached_coins_data"

    init() {}

    func fetchCoins() async throws -> [Coin] {
        guard let url = marketURL else { throw URLError(.badURL) }

        do {
            // Try API first
            let (data, response) = try await URLSession.shared.data(from: url)

            // Non-200 (e.g. 429 rate limit) returns an error body, not coins
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                throw URLError(.badServerResponse)
            }

            let coins = try Self.decodeCoins(from: data)

            // Success! Save to UserDefaults as offline backup
            userDefaults.set(data, forKey: cacheKey)

            return coins

        } catch {
            // API failed - try UserDefaults as fallback
            guard let data = userDefaults.data(forKey: cacheKey),
                  let cached = try? Self.decodeCoins(from: data) else { throw error }
            return cached
        }
    }

    /// Decodes coins one by one so a single malformed entry doesn't drop the whole list.
    private static func decodeCoins(from data: Data) throws -> [Coin] {
        let coins = try JSONDecoder().decode([LossyCoin].self, from: data).compactMap(\.coin)
        guard !coins.isEmpty else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No valid coins in response")) }
        return coins
    }
}

private struct LossyCoin: Decodable {
    let coin: Coin?

    init(from decoder: Decoder) throws {
        coin = try? Coin(from: decoder)
    }
}
