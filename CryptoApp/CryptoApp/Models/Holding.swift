//
//  Holding.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import Foundation

struct Holding: Codable, Identifiable {
    let id: UUID
    let coinId: String
    let coinSymbol: String
    var quantity: Decimal
    var averagePurchasePrice: Decimal
    let firstPurchaseDate: Date
    var lastPurchaseDate: Date
    var totalInvested: Decimal
    let imageUrl: String
    
    // CALCULATED PROPERTIES - Not stored in Firestore, computed with current market prices
    var currentValue: Decimal {
        quantity * averagePurchasePrice
    }
    
    // Calculate current value using live market price
    func currentValue(currentPrice: Decimal) -> Decimal {
        return quantity * currentPrice
    }
    
    // Calculate profit/loss using live market price
    func profitLoss(currentPrice: Decimal) -> Decimal {
        return currentValue(currentPrice: currentPrice) - totalInvested
    }
    
    // Calculate profit/loss percentage using live market price
    func profitLossPercentage(currentPrice: Decimal) -> Decimal {
        guard totalInvested > 0 else { return 0 }
        return ((currentValue(currentPrice: currentPrice) - totalInvested) / totalInvested) * 100
    }
    
    init(coinId: String, coinSymbol: String, quantity: Decimal, purchasePrice: Decimal, date: Date, imageUrl: String) {
        self.id = UUID()
        self.coinId = coinId
        self.coinSymbol = coinSymbol
        self.quantity = quantity
        self.averagePurchasePrice = purchasePrice
        self.firstPurchaseDate = date
        self.lastPurchaseDate = date
        self.totalInvested = quantity * purchasePrice
        self.imageUrl = imageUrl
    }
    
    mutating func addPurchase(quantity: Decimal, purchasePrice: Decimal, date: Date) {
        let newInvestment = quantity * purchasePrice
        let totalQuantity = self.quantity + quantity
        
        self.averagePurchasePrice = (self.totalInvested + newInvestment) / totalQuantity
        self.quantity = totalQuantity
        self.totalInvested += newInvestment
        self.lastPurchaseDate = date
    }
    
    mutating func removePurchase(quantity: Decimal) -> Bool {
        guard quantity <= self.quantity else { return false }
        
        let removedValue = quantity * self.averagePurchasePrice
        self.quantity -= quantity
        self.totalInvested -= removedValue
        
        if self.quantity <= 0 {
            self.quantity = 0
            self.totalInvested = 0
        }
        
        return true
    }
}

