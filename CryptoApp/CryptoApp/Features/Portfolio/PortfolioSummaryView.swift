//
//  PortfolioSummaryView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 06/08/2025.
//

import SwiftUI

struct PortfolioSummaryView: View {
    let totalValue: Decimal
    let totalInvestment: Decimal
    let profitLoss: Decimal
    let profitLossPercentage: Decimal
    
    var body: some View {
        VStack(spacing: Spacing.l) {
            VStack(spacing: Spacing.xs) {
                Text("Total Portfolio Value")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(totalValue, format: .usdAmount)
                    .font(.largeTitle)
                    .bold()
            }
            
            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.s) {
                    Image(systemName: profitLoss >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    Text("\(profitLoss, format: .usdChange) (\(profitLossPercentage / 100, format: .percentChangeSigned))")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(profitLoss >= 0 ? .green : .red)
                
                Text("Total Invested: \(totalInvestment, format: .usdAmount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .card(radius: Radius.large, elevated: true)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PortfolioSummaryView(totalValue: 20, totalInvestment: 200, profitLoss: 2, profitLossPercentage: 12)
}
