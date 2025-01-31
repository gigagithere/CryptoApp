import SwiftUI
import FirebaseCore

@main
struct CryptoApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
} 