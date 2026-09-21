//
//  TransactionRowView.swift
//  CryptoApp
//
//  Clean transaction history row - shows transaction data only
//

import SwiftUI
import Kingfisher

struct TransactionRowView: View {
    let transaction: Transaction
    let currentPrice: Decimal
    
    @State private var isExpanded = false
    
    private var profitLoss: Decimal {
        transaction.profitLoss(currentPrice: currentPrice)
    }
    
    private var profitLossPercentage: Decimal {
        transaction.profitLossPercentage(currentPrice: currentPrice)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                mainRow
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                transactionDetails
            }
        }
        .transition(.slide)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var mainRow: some View {
        HStack(spacing: 16) {
            // Transaction type indicator
            VStack(spacing: 5) {
                Image(systemName: transaction.type == .buy ? "plus.circle.fill" : "minus.circle.fill")
                    .font(.title2)
                    .foregroundColor(transaction.type == .buy ? .green : .red)
                    .frame(width: 28, height: 28)
                
                Text(transaction.type == .buy ? "BUY" : "SELL")
                    .secondaryText()
            }
            
            // Coin image and details
            HStack(spacing: 10) {
                KFImage(URL(string: transaction.imageUrl))
                    .resizable()
                    .placeholder {
                        Circle()
                            .fill(.gray.opacity(0.3))
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(transaction.coinSymbol.uppercased())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("• \(transaction.quantity.asQuantityString())")
                            .secondaryText()
                    }
                    
                    Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                        .secondaryText()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(transaction.totalValue.asCurrencyString())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("Details")
                            .secondaryText()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var transactionDetails: some View {
        VStack(spacing: 8) {
            Divider()
            
            Text("Transaction Details")
                .secondaryText()
                .padding(.bottom, 4)
            
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Transaction ID")
                            .secondaryText()
                        Text(transaction.id.uuidString.prefix(8).uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Price per Coin")
                            .secondaryText()
                        Text(transaction.price.asCurrencyString())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Price")
                            .secondaryText()
                        Text(currentPrice.asCurrencyString())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("P&L")
                            .secondaryText()
                        HStack(spacing: 4) {
                            Text(profitLoss.asCurrencyString())
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(profitLoss >= 0 ? .green : .red)
                            
                            Text("(\(profitLossPercentage.asPercentageString()))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(profitLoss >= 0 ? .green : .red)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

#Preview {
    TransactionRowView(
        transaction: Transaction(
            coinId: "bitcoin",
            coinSymbol: "BTC",
            quantity: Decimal(0.05),
            price: Decimal(42000),
            type: .buy,
            date: Date().addingTimeInterval(-86400 * 2),
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
        ),
        currentPrice: Decimal(45000)
    )
}
