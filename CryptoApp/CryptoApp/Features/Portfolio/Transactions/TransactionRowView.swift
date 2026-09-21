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
        
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: Spacing.l) {
                    // Transaction type indicator
                    VStack(spacing: 5) {
                        Image(systemName: isBuy ? "plus.circle.fill" : "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(isBuy ? .green : .red)
                            .frame(width: 28, height: 28)
                        
                        Text(transaction.type.rawValue)
                            .secondaryText()
                    }
                    
                    // Coin image and details
                    HStack(spacing: 10) {
                        CoinImage(url: transaction.imageUrl, symbol: transaction.coinSymbol, size: 32)
                            .clipShape(.circle)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(transaction.coinSymbol.uppercased())
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("• \(transaction.quantity, format: .quantity)")
                                    .secondaryText()
                            }
                            
                            Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                                .secondaryText()
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(transaction.totalValue, format: .usdAmount)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                Text("Details")
                                    .secondaryText()
                            }
                        }
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
