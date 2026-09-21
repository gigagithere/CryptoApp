//
//  HoldingTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

struct HoldingTests {
    private func makeHolding(quantity: Decimal, price: Decimal) -> Holding {
        Holding(coinId: "bitcoin", coinSymbol: "btc", quantity: quantity, purchasePrice: price,
                date: .now, imageUrl: "")
    }
    
    @Test func secondPurchaseAveragesThePrice() {
        var holding = makeHolding(quantity: 1, price: 100)
        
        holding.addPurchase(quantity: 1, purchasePrice: 200, date: .now)
        
        #expect(holding.quantity == 2)
        #expect(holding.totalInvested == 300)
        #expect(holding.averagePurchasePrice == 150)
    }
    
    @Test func sellingKeepsTheAverageBuyPrice() {
        var holding = makeHolding(quantity: 2, price: 150)
        
        let sold = holding.removePurchase(quantity: 1)
        
        #expect(sold)
        #expect(holding.quantity == 1)
        #expect(holding.totalInvested == 150)
        #expect(holding.averagePurchasePrice == 150)
    }
    
    @Test func sellingEverythingZeroesTheHolding() {
        var holding = makeHolding(quantity: 2, price: 150)
        
        let sold = holding.removePurchase(quantity: 2)
        
        #expect(sold)
        #expect(holding.quantity == 0)
        #expect(holding.totalInvested == 0)
    }
    
    @Test func sellingMoreThanOwnedChangesNothing() {
        var holding = makeHolding(quantity: 1, price: 100)
        
        let sold = holding.removePurchase(quantity: 2)
        
        #expect(!sold)
        #expect(holding.quantity == 1)
        #expect(holding.totalInvested == 100)
    }
    
    @Test func profitAndLossUseLivePrice() {
        let holding = makeHolding(quantity: 2, price: 100) // invested 200
        
        #expect(holding.profitLoss(currentPrice: 150) == 100)
        #expect(holding.profitLossPercentage(currentPrice: 150) == 50)
        #expect(holding.profitLossPercentage(currentPrice: 50) == -50)
    }
}
