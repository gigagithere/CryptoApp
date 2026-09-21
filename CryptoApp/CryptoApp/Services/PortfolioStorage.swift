//
//  PortfolioStorage.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 15/08/2025.
//

import Foundation

protocol PortfolioStorageProtocol {
    func loadHoldings() -> [Holding]
    func saveHoldings(_ holdings: [Holding])
    func loadTransactions() -> [Transaction]
    func saveTransactions(_ transactions: [Transaction])
}

class PortfolioStorage: PortfolioStorageProtocol {
    private let holdingsKey = "PortfolioHoldings"
    private let transactionsKey = "TransactionHistory"
    
    func loadHoldings() -> [Holding] {
        guard let data = UserDefaults.standard.data(forKey: holdingsKey),
              let decoded = try? JSONDecoder().decode([Holding].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func saveHoldings(_ holdings: [Holding]) {
        if let encoded = try? JSONEncoder().encode(holdings) {
            UserDefaults.standard.set(encoded, forKey: holdingsKey)
        }
    }
    
    func loadTransactions() -> [Transaction] {
        guard let data = UserDefaults.standard.data(forKey: transactionsKey),
              let decoded = try? JSONDecoder().decode([Transaction].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func saveTransactions(_ transactions: [Transaction]) {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
    }
}
