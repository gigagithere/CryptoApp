//
//  TransactionHistoryPage.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI

struct TransactionHistoryPage: View {
    @Environment(PortfolioViewModel.self) private var portfolio
    
    var body: some View {
        let transactions = portfolio.transactions.sorted { $0.date > $1.date }
        
        Group {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Start trading to see your transaction history here")
                )
            } else {
                VStack {
                    HStack {
                        LabeledValue(title: "Total Transactions") {
                            Text(transactions.count, format: .number)
                                .headerText()
                        }
                        
                        Spacer()
                        
                        LabeledValue(title: "Latest Activity", alignment: .trailing) {
                            if let latest = transactions.first {
                                Text(latest.date.formatted(date: .numeric, time: .omitted))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding()
                    .card()
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.s)
                    
                    ScrollView {
                        LazyVStack(spacing: Spacing.s) {
                            ForEach(transactions) { transaction in
                                TransactionRowView(
                                    transaction: transaction,
                                    currentPrice: portfolio.getCurrentPrice(for: transaction.coinId) ?? transaction.price
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .safeAreaPadding(.bottom)
                    }
                }
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
