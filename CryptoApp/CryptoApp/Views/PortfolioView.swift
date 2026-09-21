//
//  PortfolioView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI
import Kingfisher

@MainActor
struct PortfolioView: View {
    private var portfolioViewModel: any PortfolioViewModelProtocol
    private var watchlistViewModel: any WatchlistViewModelProtocol
    private let coinService: CoinServiceProtocol
    
    // INITIALIZATION - Set up view with injected ViewModels
    init(coinService: CoinServiceProtocol, portfolioViewModel: any PortfolioViewModelProtocol, watchlistViewModel: any WatchlistViewModelProtocol) {
        self.coinService = coinService
        self.portfolioViewModel = portfolioViewModel
        self.watchlistViewModel = watchlistViewModel
    }
    
    private var totalPortfolioValue: Decimal {
        portfolioViewModel.totalPortfolioValue()
    }
    
    private var totalInvestment: Decimal {
        portfolioViewModel.totalInvestment()
    }
    
    private var totalProfitLoss: Decimal {
        totalPortfolioValue - totalInvestment
    }
    
    private func fetchPrices() async {
        do {
            try await coinService.fetchCoinsIfNeeded()
        } catch {
            // Error is already stored in coinService.lastError
        }
    }
    
    private var profitLossPercentage: Decimal {
        guard totalInvestment > 0 else { return 0 }
        return (totalProfitLoss / totalInvestment) * 100
    }
    
    var body: some View {
        VStack {
            if portfolioViewModel.holdings.isEmpty {
                emptyPortfolioView
            } else {
                portfolioContentView
            }
        }
        .navigationTitle("Portfolio")
        .onChange(of: coinService.coins) { _, _ in
            // Trigger UI refresh when coin prices update
        }
        .alert("Error", isPresented: .constant(portfolioViewModel.errorMessage != nil)) {
            Button("OK") { 
                portfolioViewModel.clearError()
            }
        } message: {
            Text(portfolioViewModel.errorMessage ?? "")
        }
    }
    
    private var emptyPortfolioView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bitcoinsign.circle")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("Start Your Crypto Journey!")
                .headerText()
            
            Text("Buy some cryptocurrency to start building your portfolio and watch your investments grow")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var portfolioContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Portfolio Summary
                PortfolioSummaryView(
                    totalValue: totalPortfolioValue,
                    totalInvestment: totalInvestment,
                    profitLoss: totalProfitLoss,
                    profitLossPercentage: profitLossPercentage
                )
                .padding(.horizontal)
                
                // Portfolio Distribution Chart
                PortfolioChartView(
                    holdings: portfolioViewModel.holdings,
                    portfolioViewModel: portfolioViewModel
                )
                .padding(.horizontal)
                
                // Navigation to Detailed Views
                VStack(spacing: 16) {
                    NavigationLink(destination: CurrentHoldingsPage(holdings: portfolioViewModel.holdings, portfolioViewModel: portfolioViewModel, coinService: coinService, watchlistViewModel: watchlistViewModel)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Holdings")
                                    .headlineText()
                                    .foregroundColor(.primary)
                                Text("\(portfolioViewModel.holdings.count) holdings")
                                    .secondaryText()
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .secondaryText()
                        }
                        .cardStyle()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: TransactionHistoryPage(transactions: portfolioViewModel.transactions, portfolioViewModel: portfolioViewModel, coinService: coinService, watchlistViewModel: watchlistViewModel)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Transaction History")
                                    .headlineText()
                                    .foregroundColor(.primary)
                                Text("\(portfolioViewModel.transactions.count) transactions")
                                    .secondaryText()
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .secondaryText()
                        }
                        .cardStyle()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .padding(.bottom, 20)
        }
        .refreshable {
            await refreshPortfolio()
        }
    }
    
    @MainActor
    private func refreshPortfolio() async {
        // REFRESH - Load both coin prices and portfolio data
        await fetchPrices()
        await portfolioViewModel.loadPortfolioData()
    }
}

#Preview {
    PortfolioView(
        coinService: MockCoinService(), 
        portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
        watchlistViewModel: WatchlistViewModel(authService: AuthService.shared)
    )
}
