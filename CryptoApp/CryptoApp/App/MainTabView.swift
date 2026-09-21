//
//  MainTabView.swift
//  CryptoApp
//

import SwiftUI

/// The three tabs. Each has its own `NavigationStack`, so switching tabs keeps
/// search text, sorting, scroll position and pushed screens.
struct MainTabView: View {
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
    }
}

#Preview {
    MainTabView()
        .previewEnvironment()
}
