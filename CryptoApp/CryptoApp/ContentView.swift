//
//  ContentView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainTabView()
            } else { LoginView() }
        }
    }
}

#Preview {
    ContentView()
}
