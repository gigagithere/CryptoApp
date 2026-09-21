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
        VStack(spacing: 16) {
            // Total Value
            VStack(spacing: 4) {
                Text("Total Portfolio Value")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(totalValue.asCurrencyString())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Profit/Loss
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: profitLoss >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    Text("\(profitLoss.asCurrencyString()) (\(profitLossPercentage.asPercentageString()))")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(profitLoss >= 0 ? .green : .red)
                
                Text("Total Invested: \(totalInvestment.asCurrencyString())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview() {
    PortfolioSummaryView(totalValue: Decimal(20), totalInvestment: Decimal(200), profitLoss: Decimal(2), profitLossPercentage: Decimal(12))
}
