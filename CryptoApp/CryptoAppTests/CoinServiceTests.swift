//
//  CoinServiceTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

@MainActor
struct CoinServiceTests {
    private let repository = MockCoinRepository()
    private let service: CoinService
    
    init() {
        service = CoinService(repository: repository)
    }
    
    @Test func loadsAndIndexesCoins() async throws {
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 100)])
        
        try await service.forceRefresh()
        
        #expect(service.coins.count == 1)
        #expect(service.coin(id: "bitcoin")?.currentPrice == 100)
        #expect(service.lastUpdated != nil)
        #expect(!service.isShowingCachedData)
    }
    
    /// Regression: after a failed load `isLoading` stayed true forever, so every later
    /// refresh was silently skipped until the app was restarted.
    @Test func canRetryAfterAFailedLoad() async throws {
        repository.topResult = .failure(URLError(.notConnectedToInternet))
        
        await #expect(throws: URLError.self) { try await service.forceRefresh() }
        #expect(!service.isLoading)
        #expect(service.lastError != nil)
        
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 100)])
        try await service.forceRefresh()
        
        #expect(service.coins.count == 1)
        #expect(service.lastError == nil)
    }
    
    @Test func fetchIfNeededHonoursTheRateLimitButForceDoesNot() async throws {
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 100)])
        
        try await service.fetchCoinsIfNeeded()
        try await service.fetchCoinsIfNeeded()
        #expect(repository.topCallCount == 1)
        
        try await service.forceRefresh()
        #expect(repository.topCallCount == 2)
    }
    
    /// Regression: a refresh that arrived while another was running used to return immediately,
    /// ending the pull-to-refresh spinner before any data had arrived.
    @Test func overlappingRefreshesShareOneRequest() async throws {
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 100)])
        repository.delay = .milliseconds(150)
        
        async let first: Void = service.forceRefresh()
        async let second: Void = service.forceRefresh()
        try await first
        try await second
        
        #expect(repository.topCallCount == 1)
        #expect(service.coins.count == 1)
    }
    
    @Test func offlineBackupIsFlaggedAndDoesNotCountAsFresh() async throws {
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 100)], fromCache: true)
        
        try await service.forceRefresh()
        
        #expect(service.isShowingCachedData)
        #expect(service.lastUpdated == nil)
    }
    
    @Test func duplicateIdsDoNotCrashTheIndex() async throws {
        repository.serve([
            try TestFixtures.coin(id: "bitcoin", price: 100),
            try TestFixtures.coin(id: "bitcoin", price: 200)
        ])
        
        try await service.forceRefresh()
        
        #expect(service.coin(id: "bitcoin")?.currentPrice == 100)
    }
    
    @Test func loadsOnlyCoinsMissingFromTheTopList() async throws {
        repository.serve([try TestFixtures.coin(id: "bitcoin", price: 100)])
        repository.idsResult = .success([try TestFixtures.coin(id: "dogecoin", price: 0.1)])
        try await service.forceRefresh()
        
        await service.loadMissingCoins(ids: ["bitcoin", "dogecoin"])
        
        #expect(repository.requestedIDs == [["dogecoin"]])
        #expect(service.coin(id: "dogecoin")?.currentPrice == 0.1)
    }
}
