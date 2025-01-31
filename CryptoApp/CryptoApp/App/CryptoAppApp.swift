//
//  CryptoAppApp.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI
import FirebaseCore

@main
struct CryptoAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
