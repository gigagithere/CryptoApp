//
//  TransactionDetailsView.swift
//  CryptoApp
//
//  Expandable transaction details component
//

import SwiftUI

struct TransactionDetailsView: View {
    let transaction: Transaction
    let summary: TransactionSummary
    let currentPrice: Decimal
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            
            Text("Transaction Details")
                .secondaryText()
                .padding(.bottom, 4)
            
            VStack(spacing: 8) {
                detailRow(
                    title: "Transaction ID",
                    value: transaction.id.uuidString.prefix(8).uppercased(),
                    secondTitle: "Price per Coin",
                    secondValue: transaction.price.asCurrencyString()
                )
                
                detailRow(
                    title: "Quantity",
                    value: "\(transaction.quantity.asQuantityString()) \(transaction.coinSymbol.uppercased())",
                    secondTitle: "Current Price",
                    secondValue: currentPrice.asCurrencyString()
                )
                
                detailRow(
                    title: "Transaction Date",
                    value: transaction.date.formatted(date: .abbreviated, time: .shortened),
                    secondTitle: "P&L Percentage",
                    secondValue: summary.profitLossPercentage.asPercentageString(),
                    secondValueColor: summary.profitLoss >= 0 ? .green : .red
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
    
    private func detailRow(
        title: String,
        value: String,
        secondTitle: String,
        secondValue: String,
        secondValueColor: Color = .primary
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .secondaryText()
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(secondTitle)
                    .secondaryText()
                Text(secondValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(secondValueColor)
            }
        }
    }
}