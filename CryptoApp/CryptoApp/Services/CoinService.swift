//
//  CoinService.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 11/08/2025.
//

import Foundation
import Observation
import os

@MainActor
@Observable
final class CoinService {
    private(set) var coins: [Coin] = [] {
        didSet {
            coinsByID = Dictionary(coins.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        }
    }
    private(set) var isLoading = false
    private(set) var lastError: Error?
    private(set) var lastUpdated: Date?
    private(set) var isShowingCachedData = false

    private var coinsByID: [String: Coin] = [:]
    private var extraCoinsByID: [String: Coin] = [:]

    private let repository: CoinRepositoryProtocol
    private let cacheValidityDuration: TimeInterval = 60 // rate limiting: at most one fetch per minute
    private var inFlight: Task<Void, Error>?
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CryptoApp", category: "CoinService")

    // Dependency injection - allows for testing with a mock repository
    init(repository: CoinRepositoryProtocol = CoinRepository()) {
        self.repository = repository
    }

    /// Smart fetching - respects the 1-minute rate limit
    func fetchCoinsIfNeeded() async throws {
        try await refresh(force: false)
    }

    /// Force refresh - ignores the rate limit
    func forceRefresh() async throws {
        try await refresh(force: true)
    }

    /// Get a coin by id: the top list first, then coins loaded on demand
    func coin(id: String) -> Coin? {
        coinsByID[id] ?? extraCoinsByID[id]
    }

    func loadMissingCoins(ids: [String]) async {
        let missing = Set(ids).filter { coinsByID[$0] == nil }.sorted()
        guard !missing.isEmpty else { return }

        do {
            for coin in try await repository.fetchCoins(ids: missing) {
                extraCoinsByID[coin.id] = coin
            }
        } catch {
            Self.logger.error("Could not load prices for \(missing.joined(separator: ","), privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Private

    private func refresh(force: Bool) async throws {
        // A caller arriving while a fetch is running waits for it,
        // instead of starting a second one or returning before there is data.
        if let inFlight {
            return try await inFlight.value
        }
        guard force || shouldFetch else { return }

        // The task starts only after this synchronous section, so `inFlight` is set before it runs.
        let task = Task {
            defer { inFlight = nil }
            try await load()
        }
        inFlight = task
        try await task.value
    }

    private var shouldFetch: Bool {
        guard !coins.isEmpty, let lastUpdated else { return true }
        return Date.now.timeIntervalSince(lastUpdated) > cacheValidityDuration
    }

    private func load() async throws {
        isLoading = true
        defer { isLoading = false }
        lastError = nil

        do {
            let snapshot = try await repository.fetchTopCoins()
            coins = snapshot.coins
            isShowingCachedData = snapshot.isFromCache
            if !snapshot.isFromCache {
                lastUpdated = .now
            }
        } catch {
            if !(error is CancellationError) {
                lastError = error
            }
            throw error
        }
    }
}
