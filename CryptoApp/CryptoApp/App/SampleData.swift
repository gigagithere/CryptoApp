//
//  SampleData.swift
//  CryptoApp
//
//  Fake coins, holdings and services. They let SwiftUI previews and the UI tests
//  run the real screens without the network, Firestore or a Firebase login.
//

import Foundation

nonisolated enum SampleData {
    static let coins: [Coin] = [
        .sample,
        coin(id: "ethereum", symbol: "ETH", name: "Ethereum", price: 2800, change: -0.8, rank: 2, imageID: 279),
        coin(id: "solana", symbol: "SOL", name: "Solana", price: 95, change: 4.2, rank: 5, imageID: 4128)
    ]

    static let holdings = [
        Holding(coinId: "bitcoin", coinSymbol: "BTC", quantity: 0.25, purchasePrice: 12000,
                date: .now.addingTimeInterval(-86400 * 10), imageUrl: coins[0].image),
        Holding(coinId: "ethereum", coinSymbol: "ETH", quantity: 1.5, purchasePrice: 2900,
                date: .now.addingTimeInterval(-86400 * 7), imageUrl: coins[1].image)
    ]

    static let transactions = [
        Transaction(coinId: "bitcoin", coinSymbol: "BTC", quantity: 0.25, price: 12000, type: .buy,
                    date: .now.addingTimeInterval(-86400 * 10), imageUrl: coins[0].image),
        Transaction(coinId: "ethereum", coinSymbol: "ETH", quantity: 2, price: 2900, type: .buy,
                    date: .now.addingTimeInterval(-86400 * 7), imageUrl: coins[1].image),
        Transaction(coinId: "ethereum", coinSymbol: "ETH", quantity: 0.5, price: 3000, type: .sell,
                    date: .now.addingTimeInterval(-86400 * 2), imageUrl: coins[1].image)
    ]

    /// Built from JSON, like the real API response, so the optional fields stay nil.
    private static func coin(id: String, symbol: String, name: String, price: Double, change: Double, rank: Int, imageID: Int) -> Coin {
        let json = """
        {"id":"\(id)","symbol":"\(symbol)","name":"\(name)",\
        "image":"https://assets.coingecko.com/coins/images/\(imageID)/large/\(id).png",\
        "current_price":\(price),"market_cap":\(price * 1_000_000),"market_cap_rank":\(rank),\
        "total_volume":\(price * 50_000),"price_change_percentage_24h":\(change)}
        """
        // Static sample JSON: a failure here is a typo in this file
        return try! JSONDecoder().decode(Coin.self, from: Data(json.utf8))
    }
}

nonisolated struct SampleCoinRepository: CoinRepositoryProtocol {
    func fetchTopCoins() async throws -> MarketSnapshot {
        MarketSnapshot(coins: SampleData.coins, isFromCache: false)
    }

    func fetchCoins(ids: [String]) async throws -> [Coin] {
        SampleData.coins.filter { ids.contains($0.id) }
    }
}

nonisolated struct SamplePortfolioService: PortfolioFirestoreServiceProtocol {
    func loadHoldings(userId: String) async throws -> [Holding] { SampleData.holdings }
    func loadTransactions(userId: String) async throws -> [Transaction] { SampleData.transactions }
    func commitTrade(userId: String, transaction: Transaction, holding: Holding) async throws {}
}

nonisolated struct SampleWatchlistService: WatchlistFirestoreServiceProtocol {
    func loadWatchedCoins(userId: String) async throws -> Set<String> { ["bitcoin"] }
    func addToWatchlist(userId: String, coinId: String) async throws {}
    func removeFromWatchlist(userId: String, coinId: String) async throws {}
}
