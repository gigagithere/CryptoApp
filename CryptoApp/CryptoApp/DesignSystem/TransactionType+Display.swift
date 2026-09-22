//
//  TransactionType+Display.swift
//  CryptoApp
//

import SwiftUI

extension TransactionType {
    var title: String {
        switch self {
        case .buy: String(localized: "Buy", comment: "Trade type, also the confirm button label")
        case .sell: String(localized: "Sell", comment: "Trade type, also the confirm button label")
        }
    }

    /// Lowercase past tense, for "Successfully bought/sold …" (`title` alone can't be lowercased into that).
    var pastTenseVerb: String {
        switch self {
        case .buy: String(localized: "bought", comment: "Lowercase past tense of buy, e.g. 'Successfully bought 1 BTC'")
        case .sell: String(localized: "sold", comment: "Lowercase past tense of sell, e.g. 'Successfully sold 1 BTC'")
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
