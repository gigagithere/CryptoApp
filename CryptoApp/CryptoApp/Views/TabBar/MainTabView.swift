//
//  MainTabView.swift
//  CryptoApp
//

import SwiftUI

// MARK: - Tab Enumeration
/// Defines the available tabs in the main navigation
enum Tab: String, CaseIterable {
    case home = "Home"
    case portfolio = "Portfolio"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .portfolio:
            return "bitcoinsign.circle.fill"
        case .profile:
            return "person.crop.circle"
        }
    }
}

// MARK: - Main Tab View
/// Custom tab bar with animated transitions and CoinService
struct MainTabView: View {
    // 📱 Tab selection state
    @State private var selectedTab: Tab = .home
    
    // 🔥 Shared services for instant performance
    @State private var coinService: CoinServiceProtocol
    @State private var portfolioViewModel: any PortfolioViewModelProtocol
    @State private var watchlistViewModel: any WatchlistViewModelProtocol
    
    init() {
        let coinService = CoinService()
        let portfolioViewModel = PortfolioViewModel(authService: AuthService.shared, coinService: coinService)
        let watchlistViewModel = WatchlistViewModel(authService: AuthService.shared)
        
        self._coinService = State(initialValue: coinService)
        self._portfolioViewModel = State(initialValue: portfolioViewModel)
        self._watchlistViewModel = State(initialValue: watchlistViewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeView(coinService: coinService, portfolioViewModel: portfolioViewModel, watchlistViewModel: watchlistViewModel)  // ⚡ Inject all services
                    case .portfolio:
                        PortfolioView(coinService: coinService, portfolioViewModel: portfolioViewModel, watchlistViewModel: watchlistViewModel)  // ⚡ Inject all services
                    case .profile:
                        ProfileView()  // ✨ Profile doesn't need coin data
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            
            VStack {
                HStack {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(
                                .spring(
                                    response: 0.4,
                                    dampingFraction: 0.5,
                                    blendDuration: 0.3
                                )
                            ) {
                                selectedTab = tab
                            }
                        }) {
                            VStack {
                                Image(systemName: tab.icon)
                                    .font(.system(size: selectedTab == tab ? 26 : 24))
                                    .foregroundColor(selectedTab == tab ? .customDarkBlue : .gray)
                                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                                Text(tab.rawValue)
                                    .font(selectedTab == tab ? .footnote : .caption)
                                    .foregroundColor(selectedTab == tab ? .customDarkBlue : .gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .frame(height: 48)
            .padding(.top, 8)
            .background(
                Color(.gray)
                    .opacity(0.1)
                    .ignoresSafeArea(edges: .bottom)
            )
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .task {
            // ⚡ Single data fetch on app launch - ALL tabs benefit
            do {
                try await coinService.fetchCoinsIfNeeded()
            } catch {
                // Error is already stored in coinService.lastError
            }
            // Portfolio/watchlist don't depend on the coin fetch succeeding
            await portfolioViewModel.loadPortfolioData()
            await watchlistViewModel.loadWatchlist()
        }
        .onChange(of: AuthService.shared.userSession) { _, userSession in
            // 🔄 React to auth state changes - simple and direct
            if userSession != nil {
                Task {
                    await portfolioViewModel.loadPortfolioData()
                    await watchlistViewModel.loadWatchlist()
                }
            } else {
                // Clear data when user logs out
                portfolioViewModel.clearLocalData()
                watchlistViewModel.clearLocalData()
            }
        }
        .refreshable {
            // 🔄 Single refresh for ALL tabs
            do {
                try await coinService.forceRefresh()
            } catch {
                // Error is already stored in coinService.lastError
            }
        }
    }
}

#Preview {
    MainTabView()
}
