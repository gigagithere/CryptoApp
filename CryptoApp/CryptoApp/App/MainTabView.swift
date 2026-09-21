//
//  MainTabView.swift
//  CryptoApp
//

import SwiftUI

/// The three tabs. Each has its own `NavigationStack`, so switching tabs keeps
/// search text, sorting, scroll position and pushed screens.
struct MainTabView: View {
    @Environment(CoinService.self) private var coinService
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    HomeView()
                        .routeDestinations()
                }
            }

            Tab("Portfolio", systemImage: "bitcoinsign.circle.fill") {
                NavigationStack {
                    PortfolioView()
                        .routeDestinations()
                }
            }

            Tab("Profile", systemImage: "person.crop.circle") {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(.customDarkBlue)
        // Keeps prices fresh while the app is on screen. The task is cancelled when the app leaves the
        // foreground and starts again (with an immediate refresh) when it comes back.
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            repeat {
                try? await coinService.fetchCoinsIfNeeded() // skips itself if the last fetch is under a minute old
                try? await Task.sleep(for: .seconds(61))
            } while !Task.isCancelled
        }
    }
}

#Preview {
    MainTabView()
        .previewEnvironment()
}
