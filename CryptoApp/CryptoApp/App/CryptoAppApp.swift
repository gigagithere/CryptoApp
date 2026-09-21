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
    @AppStorage("isDarkModeOn") private var isDarkModeOn: Bool = false

    // The four objects the whole app shares. Views read them with @Environment.
    @State private var authService: AuthService
    @State private var coinService: CoinService
    @State private var portfolio: PortfolioViewModel
    @State private var watchlist: WatchlistViewModel

    init() {
        // Firebase has to be configured before anything touches Auth or Firestore,
        // which is why the objects are created here and not in property initializers.
        FirebaseApp.configure()

        // Keep Firestore data available offline
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings

        let authService = AuthService()
        let coinService = CoinService()
        _authService = State(initialValue: authService)
        _coinService = State(initialValue: coinService)
        _portfolio = State(initialValue: PortfolioViewModel(authService: authService, coinService: coinService))
        _watchlist = State(initialValue: WatchlistViewModel(authService: authService))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
                .environment(coinService)
                .environment(portfolio)
                .environment(watchlist)
                .preferredColorScheme(isDarkModeOn ? .dark : .light)
        }
    }
}
