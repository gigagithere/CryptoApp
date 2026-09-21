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
    
    // CALCULATED PROPERTIES
    var totalValue: Decimal {
        quantity * price
    }
    
    // USD value of transaction at time it occurred
    var usdValue: Decimal {
        quantity * price
    }
    
    init(coinId: String, coinSymbol: String, quantity: Decimal, price: Decimal, type: TransactionType, date: Date = Date(), imageUrl: String) {
        self.id = UUID()
        self.coinId = coinId
        self.coinSymbol = coinSymbol
        self.quantity = quantity
        self.price = price
        self.type = type
        self.date = date
        self.imageUrl = imageUrl
    }
    
    // FIFO HELPER - Check if this transaction occurred before another (for FIFO selling)
    func isBefore(_ otherTransaction: Transaction) -> Bool {
        return self.date < otherTransaction.date
    }
}


enum TransactionType: String, Codable {
    case buy = "BUY"
    case sell = "SELL"
}
