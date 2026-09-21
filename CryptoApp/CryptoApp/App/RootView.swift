//
//  RootView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

/// Shows the app or the login screen, and keeps the shared data in step with the signed-in user.
struct RootView: View {
    @Environment(AuthService.self) private var authService
    @Environment(CoinService.self) private var coinService
    @Environment(PortfolioViewModel.self) private var portfolio
    @Environment(WatchlistViewModel.self) private var watchlist

    var body: some View {
        Group {
            if authService.userID != nil {
                MainTabView()
            } else {
                AuthView()
            }
        }
        // Runs again whenever the signed-in user changes: loads on sign-in, clears on sign-out
        .task(id: authService.userID) {
            await syncData()
        }
    }

    private func syncData() async {
        guard authService.userID != nil else {
            portfolio.clearLocalData()
            watchlist.clearLocalData()
            return
        }

        // Prices first: the portfolio needs them to look up holdings outside the top list
        do {
            try await coinService.fetchCoinsIfNeeded()
        } catch is CancellationError {
            return // the user changed while loading, the next run takes over
        } catch {
            // Stored in coinService.lastError; portfolio and watchlist don't depend on it
        }
        await portfolio.loadPortfolioData()
        await watchlist.loadWatchlist()
    }
}

#Preview {
    RootView()
        .previewEnvironment()
}
