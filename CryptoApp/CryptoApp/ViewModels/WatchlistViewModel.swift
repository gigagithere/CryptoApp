//
//  WatchlistViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 15/08/2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class WatchlistViewModel {
    // STATE - What the UI displays
    private(set) var watchedCoinIds: Set<String> = []
    private(set) var isLoading = false
    private(set) var lastError: WatchlistError?

    // DEPENDENCIES - `currentUserID` is a closure so tests and previews don't need a signed-in Firebase user
    private let firestoreService: WatchlistFirestoreServiceProtocol
    private let currentUserID: @MainActor () -> String?

    init(firestoreService: WatchlistFirestoreServiceProtocol,
         currentUserID: @escaping @MainActor () -> String?) {
        self.firestoreService = firestoreService
        self.currentUserID = currentUserID
    }

    convenience init(authService: AuthService) {
        self.init(firestoreService: WatchlistFirestoreService(),
                  currentUserID: { authService.userSession?.uid })
    }

    // LOAD WATCHLIST - Get user's favorite coins from Firestore
    func loadWatchlist() async {
        guard let userId = currentUserID() else {
            lastError = .userNotAuthenticated
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            watchedCoinIds = try await firestoreService.loadWatchedCoins(userId: userId)
            lastError = nil
        } catch {
            lastError = .firestoreLoadFailed
        }
    }

    // CLEAR LOCAL DATA - Remove cached data when user logs out
    func clearLocalData() {
        watchedCoinIds = []
        lastError = nil
    }

    func isWatched(_ coinId: String) -> Bool {
        watchedCoinIds.contains(coinId)
    }

    // TOGGLE WATCHLIST - Add or remove a coin from favorites; local state changes only after the write succeeded
    func toggleWatchlist(for coinId: String) async {
        guard let userId = currentUserID() else {
            lastError = .userNotAuthenticated
            return
        }

        do {
            if watchedCoinIds.contains(coinId) {
                try await firestoreService.removeFromWatchlist(userId: userId, coinId: coinId)
                watchedCoinIds.remove(coinId)
            } else {
                try await firestoreService.addToWatchlist(userId: userId, coinId: coinId)
                watchedCoinIds.insert(coinId)
            }
            lastError = nil
        } catch {
            lastError = .firestoreSaveFailed
        }
    }
}
