//
//  CoinService.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 11/08/2025.
//

import Foundation
import SwiftUI

@MainActor
protocol CoinServiceProtocol: Observable {
    var coins: [Coin] { get }
    var isLoading: Bool { get }
    var lastError: Error? { get }
    
    func fetchCoinsIfNeeded() async throws
    func forceRefresh() async throws
    func getCoin(by id: String) -> Coin?
}

@MainActor
@Observable
final class CoinService: CoinServiceProtocol {
    // Observable properties - no @Published needed with @Observable
    var coins: [Coin] = []
    var isLoading = false
    var lastError: Error?
    
    // Private properties
    private let repository: CoinRepositoryProtocol
    private var lastFetchTime: Date?
    private let cacheValidityDuration: TimeInterval = 60 // 1 minute rate limiting
    
    // Dependency injection - allows for testing with mock repository
    init(repository: CoinRepositoryProtocol = CoinRepository()) {
        self.repository = repository
    }
    
    /// Smart fetching - respects 1-minute rate limit
    func fetchCoinsIfNeeded() async throws {
        guard !isLoading && shouldFetch() else {
            return
        }
        isLoading = true
        defer { isLoading = false }
        lastError = nil

        do {
            let freshCoins = try await repository.fetchCoins()
            coins = freshCoins
            lastFetchTime = Date()
        } catch {
            lastError = error
            throw error
        }
    }
    
    /// Force refresh - ignores rate limit
    func forceRefresh() async throws {
        lastFetchTime = nil // Reset rate limit
        try await fetchCoinsIfNeeded()
    }
    
    /// Determines if we should fetch fresh data (rate limiting)
    private func shouldFetch() -> Bool {
        // Fetch if no in-memory data
        guard !coins.isEmpty else {
            return true
        }
        
        // Check rate limit
        guard let lastFetch = lastFetchTime else {
            return true
        }
        
        let age = Date().timeIntervalSince(lastFetch)
        return age > cacheValidityDuration
    }
    
    /// Get coin by ID from cached data
    func getCoin(by id: String) -> Coin? {
        return coins.first { $0.id == id }
    }
}

@MainActor
final class MockCoinService: CoinServiceProtocol {
    var coins: [Coin] = [
        Coin(
            id: "bitcoin",
            symbol: "BTC",
            name: "Bitcoin",
            image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            currentPrice: 45000,
            marketCap: nil,
            marketCapRank: 1,
            fullyDilutedValuation: nil,
            totalVolume: nil,
            high24H: nil,
            low24H: nil,
            priceChange24H: 0,
            priceChangePercentage24H: 0,
            marketCapChange24H: nil,
            marketCapChangePercentage24H: nil,
            circulatingSupply: nil,
            totalSupply: nil,
            maxSupply: nil,
            ath: nil,
            athChangePercentage: 1.2,
            athDate: nil,
            atl: nil,
            atlChangePercentage: nil,
            atlDate: nil,
            lastUpdated: nil,
            sparklineIn7D: nil
        )
    ]
    
    var isLoading: Bool = false
    var lastError: Error? = nil
    
    func fetchCoinsIfNeeded() async throws {}
    func forceRefresh() async throws {}
    
    func getCoin(by id: String) -> Coin? {
        coins.first { $0.id == id }
    }
}
