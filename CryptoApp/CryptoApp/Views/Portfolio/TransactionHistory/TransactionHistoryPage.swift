//
//  TransactionHistoryPage.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI

struct TransactionHistoryPage: View {
    let transactions: [Transaction]
    private var portfolioViewModel: any PortfolioViewModelProtocol
    private let coinService: CoinServiceProtocol
    private var watchlistViewModel: any WatchlistViewModelProtocol
    
    init(transactions: [Transaction], portfolioViewModel: any PortfolioViewModelProtocol, coinService: CoinServiceProtocol, watchlistViewModel: any WatchlistViewModelProtocol) {
        self.transactions = transactions
        self.portfolioViewModel = portfolioViewModel
        self.coinService = coinService
        self.watchlistViewModel = watchlistViewModel
    }
    
    private var sortedTransactions: [Transaction] {
        transactions.sorted { $0.date > $1.date }
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
                        currentPrice: portfolioViewModel.getCurrentPrice(for: transaction.coinId) ?? transaction.price,
                        portfolioViewModel: portfolioViewModel,
                        coinService: coinService,
                        watchlistViewModel: watchlistViewModel
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
        TransactionHistoryPage(
            transactions: [
                Transaction(
                    coinId: "bitcoin",
                    coinSymbol: "BTC",
                    quantity: 0.1,
                    price: 40000,
                    type: .buy,
                    date: Date().addingTimeInterval(-86400 * 3),
                    imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
                ),
                Transaction(
                    coinId: "ethereum",
                    coinSymbol: "ETH",
                    quantity: 1.0,
                    price: 2700,
                    type: .buy,
                    date: Date().addingTimeInterval(-86400 * 2),
                    imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"
                ),
                Transaction(
                    coinId: "solana",
                    coinSymbol: "SOL",
                    quantity: 5.0,
                    price: 88,
                    type: .sell,
                    date: Date().addingTimeInterval(-86400),
                    imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png"
                )
            ],
            portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
            coinService: MockCoinService(),
            watchlistViewModel: WatchlistViewModel(authService: AuthService.shared)
        )
    }
}
