//
//  TransactionType.swift
//  CryptoApp
//

import Foundation

/// Direction of a trade. The raw value is what is stored in Firestore.
nonisolated enum TransactionType: String, Codable, Identifiable {
    case buy = "BUY"
    case sell = "SELL"

    var id: String { rawValue }
}
