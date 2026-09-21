//
//  WatchlistViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 15/08/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
protocol WatchlistViewModelProtocol: Observable {
    var watchedCoinIds: Set<String> { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func loadWatchlist() async
    func toggleWatchlist(for coinId: String) async
    func isWatched(_ coinId: String) -> Bool
    func clearLocalData()
    
    var watchedCoinsCount: Int { get }
    var watchedCoinsArray: [String] { get }
}

@MainActor
@Observable
class WatchlistViewModel: WatchlistViewModelProtocol {
    // STATE - What the UI displays
    var watchedCoinIds: Set<String> = []
    var isLoading = false
    var lastError: WatchlistError?
    
    // Helper for UI error display
    var errorMessage: String? {
        lastError?.localizedDescription
    }
    
    // DEPENDENCIES - Services this ViewModel needs
    private let firestoreService: WatchlistFirestoreServiceProtocol
    private let authService: AuthService
    
    // INITIALIZATION - Set up ViewModel with required services
    init(firestoreService: WatchlistFirestoreServiceProtocol = WatchlistFirestoreService(),
         authService: AuthService) {
        self.firestoreService = firestoreService
        self.authService = authService
        
        // Listen for auth changes to reload data
        observeAuthChanges()
    }

    // AUTH OBSERVATION - React to authentication state changes
    private func observeAuthChanges() {
        // Note: This will be handled by the UI layer with .onChange(of: authService.isAuthenticated)
        // No NotificationCenter needed with @Observable pattern
    }
    
    // LOAD WATCHLIST - Get user's favorite coins from Firestore
    func loadWatchlist() async {
        guard let userId = authService.userSession?.uid else {
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
    
    // CHECK IF WATCHED - See if coin is in favorites (local check)
    func isWatched(_ coinId: String) -> Bool {
        watchedCoinIds.contains(coinId)
    }
    
    // TOGGLE WATCHLIST - Add or remove coin from favorites
    func toggleWatchlist(for coinId: String) async {
        if watchedCoinIds.contains(coinId) {
            await removeFromWatchlist(coinId)
        } else {
            await addToWatchlist(coinId)
        }
    }

    // ADD TO WATCHLIST - Add coin to user's favorites
    func addToWatchlist(_ coinId: String) async {
        guard let userId = authService.userSession?.uid else {
            lastError = .userNotAuthenticated
            return
        }
        
        do {
            try await firestoreService.addToWatchlist(userId: userId, coinId: coinId)
            watchedCoinIds.insert(coinId)
            lastError = nil
        } catch {
            lastError = .firestoreSaveFailed
        }
    }
    
    // REMOVE FROM WATCHLIST - Remove coin from user's favorites
    func removeFromWatchlist(_ coinId: String) async {
        guard let userId = authService.userSession?.uid else {
            lastError = .userNotAuthenticated
            return
        }
        
        do {
            try await firestoreService.removeFromWatchlist(userId: userId, coinId: coinId)
            watchedCoinIds.remove(coinId)
            lastError = nil
        } catch {
            lastError = .firestoreSaveFailed
        }
    }
    
    // COMPUTED PROPERTIES
    var watchedCoinsCount: Int {
        watchedCoinIds.count
    }

    var watchedCoinsArray: [String] {
        Array(watchedCoinIds)
    }
}
