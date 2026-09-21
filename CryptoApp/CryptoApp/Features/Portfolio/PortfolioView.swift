//
//  PortfolioView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI

struct PortfolioView: View {
    @Environment(CoinService.self) private var coinService
    @Environment(PortfolioViewModel.self) private var portfolio
    
    var body: some View {
        @Bindable var portfolio = portfolio
        
        Group {
            if portfolio.holdings.isEmpty {
                ContentUnavailableView(
                    "Start Your Crypto Journey!",
                    systemImage: "bitcoinsign.circle",
                    description: Text("Buy some cryptocurrency to start building your portfolio and watch your investments grow")
                )
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        PortfolioSummaryView(
                            totalValue: portfolio.totalPortfolioValue(),
                            totalInvestment: portfolio.totalInvestment(),
                            profitLoss: portfolio.totalProfitLoss(),
                            profitLossPercentage: portfolio.totalProfitLossPercentage()
                        )
                        
                        PortfolioChartView()
                        
                        VStack(spacing: 16) {
                            PortfolioLinkRow(title: "Current Holdings",
                                             subtitle: "\(portfolio.holdings.count) holdings",
                                             route: .holdings)
                            PortfolioLinkRow(title: "Transaction History",
                                             subtitle: "\(portfolio.transactions.count) transactions",
                                             route: .transactions)
                        }
                    }
                    .padding(.horizontal)
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
        .navigationTitle("Portfolio")
        .alert("Error", isPresented: $portfolio.showsError) {
            Button("OK") { }
        } message: {
            Text(portfolio.errorMessage ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        PortfolioView()
            .routeDestinations()
    }
    .previewEnvironment()
}
