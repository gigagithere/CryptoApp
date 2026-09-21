//
//  MainTabView.swift
//  CryptoApp
//

import SwiftUI

// MARK: - Main Tab View
/// Custom tab bar with animated transitions
struct MainTabView: View {
    @Environment(CoinService.self) private var coinService
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .portfolio:
                        PortfolioView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            
            VStack {
                HStack {
                    ForEach(AppTab.allCases, id: \.self) { tab in
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
        .refreshable {
            try? await coinService.forceRefresh() // an error is already stored in coinService.lastError
        }
    }
}

#Preview {
    MainTabView()
        .previewEnvironment()
}
