//
//  TabView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 12/12/2024.
//

import SwiftUI

struct MainTabView: View {
    @State private var isLoggedIn: Bool = false // Śledzi stan logowania
    
    var body: some View {
        TabView {
            // Pierwsza zakładka - HomeView
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
          
            LoginView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}



#Preview {
    MainTabView()
}
