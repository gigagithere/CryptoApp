//
//  TransactionDetailsView.swift
//  CryptoApp
//

import SwiftUI

/// The expanded part of a transaction row: price then and now, and the profit or loss since.
struct TransactionDetailsView: View {
    let transaction: Transaction
    let currentPrice: Decimal

    var body: some View {
        let profitLoss = transaction.profitLoss(currentPrice: currentPrice)
        let profitLossPercentage = transaction.profitLossPercentage(currentPrice: currentPrice)

        VStack(spacing: 8) {
            Divider()

            Text("Transaction Details")
                .secondaryText()
                .padding(.bottom, 4)

            HStack {
                LabeledValue(title: "Transaction ID") {
                    Text(transaction.id.uuidString.prefix(8).uppercased())
                        .font(.caption.weight(.medium))
                }

                Spacer()

                LabeledValue(title: "Price per Coin", alignment: .trailing) {
                    Text(transaction.price, format: .usd)
                        .font(.caption.weight(.medium))
                }
            }

            HStack {
                LabeledValue(title: "Current Price") {
                    Text(currentPrice, format: .usd)
                        .font(.caption.weight(.medium))
                }

                Spacer()

                LabeledValue(title: "P&L", alignment: .trailing) {
                    Text("\(profitLoss, format: .usd) (\(profitLossPercentage / 100, format: .percentChange))")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(profitLoss >= 0 ? .green : .red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

#Preview {
    TransactionDetailsView(
        transaction: Transaction(coinId: "bitcoin", coinSymbol: "BTC", quantity: 0.05, price: 42000, type: .buy,
                                 imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
        currentPrice: 45000
    )
    .padding()
}
