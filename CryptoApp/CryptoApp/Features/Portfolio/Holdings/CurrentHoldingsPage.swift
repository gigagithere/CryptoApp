//
//  CurrentHoldingsPage.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI
import Kingfisher


struct CurrentHoldingsPage: View {
    @Environment(PortfolioViewModel.self) private var portfolio
    
    private var holdings: [Holding] {
        portfolio.holdings
    }

    var body: some View {
        VStack {
            if holdings.isEmpty {
                emptyStateView
            } else {
                portfolioSummaryView
                holdingsListView
            }
        }
        .navigationTitle("Current Holdings")
        .navigationBarTitleDisplayMode(.large)
    }
    
    
    // MARK: - Computed Properties for Clean UI
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bitcoinsign.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Holdings Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start trading to build your portfolio")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var portfolioSummaryView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Holdings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(holdings.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Portfolio Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(portfolio.totalPortfolioValue().asCurrencyString())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }
    
    private var holdingsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(holdings) { holding in
                    CurrentHoldingsRowView(
                        holding: holding,
                        currentPrice: portfolio.currentPrice(for: holding)
                    )
                }
            }
            .padding(.horizontal, 20)
            .safeAreaPadding(.bottom)
        }
    }
    
}

#Preview {
    NavigationStack {
        CurrentHoldingsPage()
    }
    .previewEnvironment()
}
