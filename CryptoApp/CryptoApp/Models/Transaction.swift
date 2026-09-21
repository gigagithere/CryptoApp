//
//  Transaction.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 06/08/2025.
//

import Foundation

struct Transaction: Codable, Identifiable {
    let id: UUID
    let coinId: String
    let coinSymbol: String
    let quantity: Decimal
    let price: Decimal // Price at time of transaction
    let type: TransactionType
    let date: Date
    let imageUrl: String

    var totalValue: Decimal {
        quantity * price
    }

    init(coinId: String, coinSymbol: String, quantity: Decimal, price: Decimal, type: TransactionType, date: Date = .now, imageUrl: String) {
        self.id = UUID()
        self.coinId = coinId
        self.coinSymbol = coinSymbol
        self.quantity = quantity
        self.price = price
        self.type = type
        self.date = date
        self.imageUrl = imageUrl
    }

    /// What this trade would be worth (buy) or would have saved you (sell) at today's price.
    func profitLoss(currentPrice: Decimal) -> Decimal {
        let currentValue = quantity * currentPrice
        return type == .buy ? currentValue - totalValue : totalValue - currentValue
    }

    func profitLossPercentage(currentPrice: Decimal) -> Decimal {
        guard totalValue > 0 else { return 0 }
        return (profitLoss(currentPrice: currentPrice) / totalValue) * 100
    }
}
