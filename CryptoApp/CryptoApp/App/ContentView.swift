//
//  ContentView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct ContentView: View {
    private let authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.userSession != nil {
                MainTabView()
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    ContentView()
}
