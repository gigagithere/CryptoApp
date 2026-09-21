//
//  CryptoAppApp.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct CryptoAppApp: App {
    @AppStorage("appTheme") private var theme: AppTheme = .system

    // The four objects the whole app shares. Views read them with @Environment.
    @State private var authService: AuthService
    @State private var coinService: CoinService
    @State private var portfolio: PortfolioViewModel
    @State private var watchlist: WatchlistViewModel

    init() {
        // The old Dark Mode switch became a System / Light / Dark choice
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "appTheme") == nil, defaults.bool(forKey: "isDarkModeOn") {
            defaults.set(AppTheme.dark.rawValue, forKey: "appTheme")
        }

        // Firebase has to be configured before anything touches Auth or Firestore,
        // which is why the objects are created here and not in property initializers.
        FirebaseApp.configure()

        // Keep Firestore data available offline
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings

        let authService: AuthService
        let coinService: CoinService
        let portfolio: PortfolioViewModel
        let watchlist: WatchlistViewModel

        if ProcessInfo.processInfo.arguments.contains("-uiTesting") {
            // UI tests can't reach the network or log in: run on sample data as a fake signed-in user
            let userID = "ui-test-user"
            authService = AuthService(uiTestUserID: userID)
            coinService = CoinService(repository: SampleCoinRepository())
            portfolio = PortfolioViewModel(firestoreService: SamplePortfolioService(),
                                           coinService: coinService,
                                           currentUserID: { userID })
            watchlist = WatchlistViewModel(firestoreService: SampleWatchlistService(),
                                           currentUserID: { userID })
        } else {
            authService = AuthService()
            coinService = CoinService()
            portfolio = PortfolioViewModel(authService: authService, coinService: coinService)
            watchlist = WatchlistViewModel(authService: authService)
        }

        _authService = State(initialValue: authService)
        _coinService = State(initialValue: coinService)
        _portfolio = State(initialValue: portfolio)
        _watchlist = State(initialValue: watchlist)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
                .environment(coinService)
                .environment(portfolio)
                .environment(watchlist)
                .preferredColorScheme(theme.colorScheme)
        }
    }
}
