//
//  PortfolioView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI
import Kingfisher

struct PortfolioView: View {
    @Environment(CoinService.self) private var coinService
    @Environment(PortfolioViewModel.self) private var portfolio
    
    var body: some View {
        VStack {
            if portfolio.holdings.isEmpty {
                emptyPortfolioView
            } else {
                portfolioContentView
            }
        }
        .navigationTitle("Portfolio")
        .alert("Error", isPresented: .constant(portfolio.errorMessage != nil)) {
            Button("OK") { 
                portfolio.clearError()
            }
        } message: {
            Text(portfolio.errorMessage ?? "")
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
                    totalValue: portfolio.totalPortfolioValue(),
                    totalInvestment: portfolio.totalInvestment(),
                    profitLoss: portfolio.totalProfitLoss(),
                    profitLossPercentage: portfolio.totalProfitLossPercentage()
                )
                .padding(.horizontal)
                
                // Portfolio Distribution Chart
                PortfolioChartView()
                .padding(.horizontal)
                
                // Navigation to Detailed Views
                VStack(spacing: 16) {
                    NavigationLink(destination: CurrentHoldingsPage()) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Holdings")
                                    .headlineText()
                                    .foregroundColor(.primary)
                                Text("\(portfolio.holdings.count) holdings")
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
                    
                    NavigationLink(destination: TransactionHistoryPage()) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Transaction History")
                                    .headlineText()
                                    .foregroundColor(.primary)
                                Text("\(portfolio.transactions.count) transactions")
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
            // REFRESH - Load both coin prices and portfolio data
            try? await coinService.fetchCoinsIfNeeded()
            await portfolio.loadPortfolioData()
        }
    }
}

#Preview {
    NavigationStack {
        PortfolioView()
    }
    .previewEnvironment()
}
