//
//  CoinRepositoryTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

@Suite(.serialized)
struct CoinRepositoryTests {
    private let defaults: UserDefaults
    private let repository: CoinRepository
    private let validBody = #"[{"id":"bitcoin","symbol":"btc","name":"Bitcoin","image":"x","current_price":100}]"#
    
    init() throws {
        let suite = "CoinRepositoryTests-\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suite))
        repository = CoinRepository(session: StubURLProtocol.makeSession(), userDefaults: defaults)
    }
    
    @Test func returnsFreshCoinsAndRemembersThemOffline() async throws {
        StubURLProtocol.handler = { [validBody] in StubURLProtocol.respond(status: 200, body: validBody, for: $0) }
        
        let snapshot = try await repository.fetchTopCoins()
        
        #expect(snapshot.coins.map(\.id) == ["bitcoin"])
        #expect(!snapshot.isFromCache)
        #expect(defaults.data(forKey: "cached_coins_data") != nil)
    }
    
    @Test func fallsBackToTheOfflineBackupWhenTheServerFails() async throws {
        StubURLProtocol.handler = { [validBody] in StubURLProtocol.respond(status: 200, body: validBody, for: $0) }
        _ = try await repository.fetchTopCoins()
        
        StubURLProtocol.handler = { StubURLProtocol.respond(status: 429, body: "{}", for: $0) }
        let snapshot = try await repository.fetchTopCoins()
        
        #expect(snapshot.isFromCache)
        #expect(snapshot.coins.map(\.id) == ["bitcoin"])
    }
    
    @Test func failsWhenThereIsNoBackupToFallBackTo() async {
        StubURLProtocol.handler = { StubURLProtocol.respond(status: 500, for: $0) }
        
        await #expect(throws: URLError.self) { try await repository.fetchTopCoins() }
    }
    
    /// A cancelled request must surface as cancellation, not be answered with stale data.
    @Test func cancellationIsNotReplacedByOldData() async throws {
        StubURLProtocol.handler = { [validBody] in StubURLProtocol.respond(status: 200, body: validBody, for: $0) }
        _ = try await repository.fetchTopCoins() // fills the backup
        
        StubURLProtocol.handler = { _ in throw URLError(.cancelled) }
        
        await #expect(throws: URLError.self) { try await repository.fetchTopCoins() }
    }
    
    @Test func requestsSpecificCoinsByIdWithoutSparklines() async throws {
        nonisolated(unsafe) var requestedURL: URL?
        StubURLProtocol.handler = { [validBody] request in
            requestedURL = request.url
            return StubURLProtocol.respond(status: 200, body: validBody, for: request)
        }
        
        _ = try await repository.fetchCoins(ids: ["dogecoin", "ripple"])
        
        let items = try #require(requestedURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems })
        #expect(items.contains(URLQueryItem(name: "ids", value: "dogecoin,ripple")))
        #expect(items.contains(URLQueryItem(name: "sparkline", value: "false")))
    }
    
    @Test func emptyIdListMakesNoRequest() async throws {
        StubURLProtocol.handler = { _ in throw URLError(.badURL) }
        
        let coins = try await repository.fetchCoins(ids: [])
        
        #expect(coins.isEmpty)
    }
}
