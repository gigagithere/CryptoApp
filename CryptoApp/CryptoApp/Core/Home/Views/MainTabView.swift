//
//  TabView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 12/12/2024.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    init() {
        setupTabBarAppearance()
    }

    var body: some View {
        TabView {
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

    func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()

        let selectedAppearance = UITabBarItemAppearance()
        selectedAppearance.normal.iconColor = UIColor.gray
        selectedAppearance.selected.iconColor = UIColor.yellow
        selectedAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        selectedAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.blue
        ]

        tabBarAppearance.stackedLayoutAppearance = selectedAppearance
        tabBarAppearance.inlineLayoutAppearance = selectedAppearance
        tabBarAppearance.compactInlineLayoutAppearance = selectedAppearance

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

#Preview {
    MainTabView()
}
