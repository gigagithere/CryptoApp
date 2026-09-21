//
//  CoinRepository.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import Foundation

nonisolated protocol CoinRepositoryProtocol: Sendable {
    /// The top coins by market cap (with 7-day sparklines).
    func fetchTopCoins() async throws -> MarketSnapshot
    /// Specific coins by CoinGecko id, e.g. holdings that dropped out of the top list.
    func fetchCoins(ids: [String]) async throws -> [Coin]
}

/// `@unchecked Sendable`: the only state is two immutable references (`URLSession` and `UserDefaults`),
/// and both are documented as safe to use from any thread.
nonisolated final class CoinRepository: CoinRepositoryProtocol, @unchecked Sendable {
    private let session: URLSession
    private let userDefaults: UserDefaults
    private let cacheKey = "cached_coins_data"

    init(session: URLSession = .shared, userDefaults: UserDefaults = .standard) {
        self.session = session
        self.userDefaults = userDefaults
    }

    @concurrent
    func fetchTopCoins() async throws -> MarketSnapshot {
        let url = try marketsURL(extraItems: [
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: "50"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "sparkline", value: "true")
        ])

        do {
            let data = try await download(url)
            let coins = try Self.decodeCoins(from: data)
            guard !coins.isEmpty else { throw URLError(.cannotParseResponse) }

            // Success: keep the raw response as an offline backup
            userDefaults.set(data, forKey: cacheKey)
            return MarketSnapshot(coins: coins, isFromCache: false)
        } catch {
            // A cancelled request is not a failure to paper over with old data
            if error is CancellationError || (error as? URLError)?.code == .cancelled {
                throw error
            }
            guard let data = userDefaults.data(forKey: cacheKey),
                  let cached = try? Self.decodeCoins(from: data),
                  !cached.isEmpty else { throw error }
            return MarketSnapshot(coins: cached, isFromCache: true)
        }
    }

    @concurrent
    func fetchCoins(ids: [String]) async throws -> [Coin] {
        guard !ids.isEmpty else { return [] }
        let url = try marketsURL(extraItems: [
            URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
            URLQueryItem(name: "sparkline", value: "false")
        ])
        return try Self.decodeCoins(from: try await download(url))
    }

    /// Decodes coins one by one so a single malformed entry doesn't drop the whole list.
    /// Throws if the payload isn't a JSON array at all (e.g. an error object from a rate limit).
    static func decodeCoins(from data: Data) throws -> [Coin] {
        try JSONDecoder().decode([LossyCoin].self, from: data).compactMap(\.coin)
    }

    private func marketsURL(extraItems: [URLQueryItem]) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.coingecko.com"
        components.path = "/api/v3/coins/markets"
        components.queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "price_change_percentage", value: "24h")
        ] + extraItems
        guard let url = components.url else { throw URLError(.badURL) }
        return url
    }

    private func download(_ url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        // Non-2xx (e.g. 429 rate limit) returns an error body, not coins
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

private nonisolated struct LossyCoin: Decodable {
    let coin: Coin?

    init(from decoder: Decoder) throws {
        coin = try? Coin(from: decoder)
    }
}
