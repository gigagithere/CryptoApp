import SwiftUI

enum Tab: String, CaseIterable {
    case home = "Home"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .profile:
            return "person.crop.circle"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var authViewModel = AuthService()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var topMoversVM = TopMoversViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView(homeVM: homeViewModel, topMoversVM: topMoversVM)
                case .profile:
                    ProfileView(authViewModel: authViewModel)
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    MainTabView()
}
