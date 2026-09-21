//
//  TransactionHistoryPage.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI

struct TransactionHistoryPage: View {
    @Environment(PortfolioViewModel.self) private var portfolio
    
    private var sortedTransactions: [Transaction] {
        portfolio.transactions.sorted { $0.date > $1.date }
    }
    
    // MARK: - Computed Properties for Clean UI
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Transactions Yet")
                .headerText()
            
            Text("Start trading to see your transaction history here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var transactionSummaryView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Transactions")
                        .secondaryText()
                    Text("\(sortedTransactions.count)")
                        .headerText()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Latest Activity")
                        .secondaryText()
                    if let latestTransaction = sortedTransactions.first {
                        Text(latestTransaction.date.asShortDateString())
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .cardStyle()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
    
    private var transactionListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(sortedTransactions) { transaction in
                    TransactionRowView(
                        transaction: transaction,
                        currentPrice: portfolio.getCurrentPrice(for: transaction.coinId) ?? transaction.price
                    )
                }
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.bottom)
        }
    }
    
    var body: some View {
        VStack {
            if sortedTransactions.isEmpty {
                emptyStateView
            } else {
                transactionSummaryView
                transactionListView
            }
        }
        .navigationTitle("Transaction History")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        TransactionHistoryPage()
    }
    .previewEnvironment()
}
