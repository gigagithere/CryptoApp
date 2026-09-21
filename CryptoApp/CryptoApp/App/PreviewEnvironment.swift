//
//  PreviewEnvironment.swift
//  CryptoApp
//
//  The `.previewEnvironment()` helper for SwiftUI previews. `#Preview` bodies are
//  type-checked in every configuration, so this file is too, but the app never calls it.
//

import SwiftUI
import FirebaseCore

extension View {
    /// Injects the same shared objects as `CryptoAppApp`, filled with sample data
    /// (no network and no Firestore), so a preview can render any screen.
    func previewEnvironment() -> some View {
        modifier(PreviewEnvironment())
    }
}

private struct PreviewEnvironment: ViewModifier {
    @State private var authService: AuthService
    @State private var coinService: CoinService
    @State private var portfolio: PortfolioViewModel
    @State private var watchlist: WatchlistViewModel

    init() {
        // AuthService talks to Firebase Auth, which needs a configured app (the real app does it in CryptoAppApp)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let authService = AuthService()
        let coinService = CoinService(repository: SampleCoinRepository())
        _authService = State(initialValue: authService)
        _coinService = State(initialValue: coinService)
        _portfolio = State(initialValue: PortfolioViewModel(firestoreService: SamplePortfolioService(),
                                                            coinService: coinService,
                                                            currentUserID: { "preview-user" }))
        _watchlist = State(initialValue: WatchlistViewModel(firestoreService: SampleWatchlistService(),
                                                            currentUserID: { "preview-user" }))
    }

    func body(content: Content) -> some View {
        content
            .environment(authService)
            .environment(coinService)
            .environment(portfolio)
            .environment(watchlist)
            .task {
                try? await coinService.fetchCoinsIfNeeded()
                await portfolio.loadPortfolioData()
                await watchlist.loadWatchlist()
            }
    }
}
