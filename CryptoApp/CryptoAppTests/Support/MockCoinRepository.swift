//
//  MockCoinRepository.swift
//  CryptoAppTests
//

import Foundation
@testable import CryptoApp

/// A repository whose answers and timing are controlled by the test.
final class MockCoinRepository: CoinRepositoryProtocol {
    var topResult: Result<MarketSnapshot, Error> = .success(MarketSnapshot(coins: [], isFromCache: false))
    var idsResult: Result<[Coin], Error> = .success([])
    /// Makes `fetchTopCoins` take this long, so tests can overlap requests.
    var delay: Duration = .zero
    
    private(set) var topCallCount = 0
    private(set) var requestedIDs: [[String]] = []
    
    func fetchTopCoins() async throws -> MarketSnapshot {
        topCallCount += 1
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        return try topResult.get()
    }
    
    func fetchCoins(ids: [String]) async throws -> [Coin] {
        requestedIDs.append(ids)
        return try idsResult.get()
    }
    
    /// Convenience: the repository returns these coins as fresh data.
    func serve(_ coins: [Coin], fromCache: Bool = false) {
        topResult = .success(MarketSnapshot(coins: coins, isFromCache: fromCache))
    }
}
