//
//  Color+Coin.swift
//  CryptoApp
//

import SwiftUI

extension Color {
    private static let coinPalette: [Color] = [
        .blue, .green, .orange, .purple, .pink, .red, .yellow, .cyan,
        .mint, .indigo, .teal, .brown,
        Color(red: 0.8, green: 0.2, blue: 0.6), Color(red: 0.2, green: 0.8, blue: 0.4),
        Color(red: 0.9, green: 0.6, blue: 0.1), Color(red: 0.3, green: 0.7, blue: 0.9),
        Color(red: 0.7, green: 0.3, blue: 0.8), Color(red: 0.1, green: 0.5, blue: 0.8),
        Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.5, green: 0.8, blue: 0.3)
    ]
    
    /// A color for a coin symbol that is the same on every launch.
    /// (`Hasher` is randomly seeded per process, so colors built from it changed on each start.)
    static func coin(_ symbol: String) -> Color {
        var hash: UInt64 = 5381 // djb2
        for byte in symbol.uppercased().utf8 {
            hash = (hash &* 33) &+ UInt64(byte)
        }
        return coinPalette[Int(hash % UInt64(coinPalette.count))]
    }
}
