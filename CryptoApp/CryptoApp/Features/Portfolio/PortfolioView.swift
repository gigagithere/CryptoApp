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
        Group {
            if !portfolio.hasLoaded && portfolio.errorMessage == nil {
                ProgressView("Loading portfolio…")
                    .controlSize(.large)
            } else if portfolio.holdings.isEmpty {
                if let message = portfolio.errorMessage {
                    ContentUnavailableView {
                        Label("Couldn't Load Portfolio", systemImage: "wifi.slash")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try Again") {
                            Task { await portfolio.loadPortfolioData() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    ContentUnavailableView(
                        "Start Your Crypto Journey!",
                        systemImage: "bitcoinsign.circle",
                        description: Text("Buy some cryptocurrency to start building your portfolio and watch your investments grow")
                    )
                }
            } else {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        if let message = portfolio.errorMessage {
                            StatusBanner(systemImage: "exclamationmark.triangle", tint: .orange, message: Text(verbatim: message))
                        }
                        
                        PortfolioSummaryView(
                            totalValue: portfolio.totalPortfolioValue(),
                            totalInvestment: portfolio.totalInvestment(),
                            profitLoss: portfolio.totalProfitLoss(),
                            profitLossPercentage: portfolio.totalProfitLossPercentage()
                        )
                        
                        PortfolioChartView()
                        
                        VStack(spacing: Spacing.l) {
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
                    .padding(.bottom, Spacing.xl)
                }
                .refreshable {
                    // REFRESH - Load both coin prices and portfolio data
                    try? await coinService.fetchCoinsIfNeeded()
                    await portfolio.loadPortfolioData()
                }
            }
        }
        .navigationTitle("Portfolio")
    }
}

#Preview {
    NavigationStack {
        PortfolioView()
            .routeDestinations()
    }
    .previewEnvironment()
}
