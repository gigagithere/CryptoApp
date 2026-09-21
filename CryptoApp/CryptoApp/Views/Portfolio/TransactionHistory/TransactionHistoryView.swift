//
//  TransactionHistoryView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI
import Kingfisher

struct TransactionHistoryView: View {
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationLink(destination: TransactionHistoryPage(transactions: transactions, portfolioViewModel: portfolioViewModel, coinService: coinService, watchlistViewModel: watchlistViewModel)) {
                VStack(spacing: 0) {
                    HStack {
                        Text("Transaction History")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("\(transactions.count) transactions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4) // Add some vertical padding for better touch target
                }
            }
            .buttonStyle(.plain)
            
            if sortedTransactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Your buy transactions will appear here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(sortedTransactions.prefix(3)) { transaction in
                        TransactionRowView(
                            transaction: transaction,
                            currentPrice: portfolioViewModel.getCurrentPrice(for: transaction.coinId) ?? transaction.price,
                            portfolioViewModel: portfolioViewModel,
                            coinService: coinService,
                            watchlistViewModel: watchlistViewModel
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}



#Preview {
    TransactionHistoryView(
        transactions: [
            Transaction(
                coinId: "bitcoin",
                coinSymbol: "WSTETHaaa",
                quantity: 0.05,
                price: 42000,
                type: .buy,
                date: Date().addingTimeInterval(-86400 * 2),
                imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
            ),
            Transaction(
                coinId: "ethereum",
                coinSymbol: "ETH",
                quantity: 0.8,
                price: 2800,
                type: .buy,
                date: Date().addingTimeInterval(-86400 * 1),
                imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"
            ),
            Transaction(
                coinId: "solana",
                coinSymbol: "SOL",
                quantity: 10.0,
                price: 90,
                type: .sell,
                date: Date(),
                imageUrl: "https://assets.coingecko.com/coins/images/4128/large/solana.png"
            )
        ],
        portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
        coinService: MockCoinService(),
        watchlistViewModel: WatchlistViewModel(authService: AuthService.shared)
    )
}
