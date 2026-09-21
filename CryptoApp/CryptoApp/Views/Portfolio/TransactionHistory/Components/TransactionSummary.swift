//
//  TransactionSummary.swift
//  CryptoApp
//
//  Transaction calculations and summary data
//

import Foundation

struct TransactionSummary {
    let transaction: Transaction
    let currentPrice: Decimal
    
    var currentValue: Decimal {
        transaction.quantity * currentPrice
    }
    
    var profitLoss: Decimal {
        if transaction.type == .buy {
            return currentValue - transaction.totalValue
        } else {
            return transaction.totalValue - currentValue // For sells, we want to show profit from selling
        }
    }
    
    var profitLossPercentage: Decimal {
        guard transaction.totalValue > 0 else { return 0 }
        return (profitLoss / transaction.totalValue) * 100
    }
}