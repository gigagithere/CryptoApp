//
//  TransactionType+Display.swift
//  CryptoApp
//

import SwiftUI

extension TransactionType {
    var title: String {
        switch self {
        case .buy: "Buy"
        case .sell: "Sell"
        }
    }

    var color: Color {
        switch self {
        case .buy: .green
        case .sell: .red
        }
    }

    var systemImage: String {
        switch self {
        case .buy: "arrow.up.circle.fill"
        case .sell: "arrow.down.circle.fill"
        }
    }
}
