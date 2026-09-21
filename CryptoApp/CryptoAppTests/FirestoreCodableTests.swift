//
//  FirestoreCodableTests.swift
//  CryptoAppTests
//
//  Money is stored as Decimal. These tests document how that survives Firestore's Codable.
//

import Foundation
import FirebaseFirestore
import Testing
@testable import CryptoApp

struct FirestoreCodableTests {
    @Test func holdingSurvivesAnEncodeDecodeRoundTripExactly() throws {
        let quantity = try #require(Decimal(string: "0.12345678", locale: Locale(identifier: "en_US_POSIX")))
        let price = try #require(Decimal(string: "85688.12", locale: Locale(identifier: "en_US_POSIX")))
        let holding = Holding(coinId: "bitcoin", coinSymbol: "btc", quantity: quantity,
                              purchasePrice: price, date: .now, imageUrl: "x")
        
        let stored = try Firestore.Encoder().encode(holding)
        print("Stored quantity representation:", String(describing: stored["quantity"]))
        let restored = try Firestore.Decoder().decode(Holding.self, from: stored)
        
        #expect(restored.quantity == quantity)
        #expect(restored.averagePurchasePrice == price)
        #expect(restored.totalInvested == quantity * price)
    }
    
    @Test func transactionSurvivesAnEncodeDecodeRoundTripExactly() throws {
        let quantity = try #require(Decimal(string: "1.5", locale: Locale(identifier: "en_US_POSIX")))
        let price = try #require(Decimal(string: "0.9997", locale: Locale(identifier: "en_US_POSIX")))
        let transaction = CryptoApp.Transaction(coinId: "tether", coinSymbol: "usdt", quantity: quantity,
                                                price: price, type: .sell, date: .now, imageUrl: "x")
        
        let stored = try Firestore.Encoder().encode(transaction)
        let restored = try Firestore.Decoder().decode(CryptoApp.Transaction.self, from: stored)
        
        #expect(restored.quantity == quantity)
        #expect(restored.price == price)
        #expect(restored.type == .sell)
    }
}
