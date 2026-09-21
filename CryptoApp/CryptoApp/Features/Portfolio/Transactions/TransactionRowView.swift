//
//  TransactionRowView.swift
//
//  One buy or sell in the history; tap to expand the details.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let currentPrice: Decimal
    
    @State private var isExpanded = false
    
    var body: some View {
        let isBuy = transaction.type == .buy
        let symbol = transaction.coinSymbol.uppercased()
        
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: Spacing.m) {
                    Image(systemName: isBuy ? "plus.circle.fill" : "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(isBuy ? .green : .red)
                    
                    CoinImage(url: transaction.imageUrl, symbol: transaction.coinSymbol, size: 32)
                        .clipShape(.circle)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // The wording says what happened, so the color isn't the only clue
                        Text(isBuy ? "Bought \(transaction.quantity, format: .quantity) \(symbol)"
                                   : "Sold \(transaction.quantity, format: .quantity) \(symbol)")
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Text(transaction.date, format: .dateTime.day().month(.abbreviated).hour().minute())
                            .secondaryText()
                            .lineLimit(1)
                    }
                    
                    Spacer(minLength: Spacing.s)
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(transaction.totalValue, format: .usdAmount)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
            }
            .buttonStyle(.plain)
            .accessibilityHint(isExpanded ? "Hides details" : "Shows details")
            
            if isExpanded {
                TransactionDetailsView(transaction: transaction, currentPrice: currentPrice)
            }
        }
        .transition(.slide)
        .card(elevated: true)
    }
}

#Preview {
    TransactionRowView(
        transaction: Transaction(
            coinId: "bitcoin",
            coinSymbol: "BTC",
            quantity: 0.05,
            price: 42000,
            type: .buy,
            date: .now.addingTimeInterval(-86400 * 2),
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
        ),
        currentPrice: 45000
    )
}
