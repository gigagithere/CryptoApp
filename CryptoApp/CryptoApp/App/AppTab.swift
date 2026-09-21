//
//  AppTab.swift
//  CryptoApp
//

import Foundation

/// The tabs of the main screen.
enum AppTab: String, CaseIterable {
    case home = "Home"
    case portfolio = "Portfolio"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .portfolio: "bitcoinsign.circle.fill"
        case .profile: "person.crop.circle"
        }
    }
}
