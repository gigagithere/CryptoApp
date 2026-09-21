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
            VStack(spacing: 4) {
                Text("Total Portfolio Value")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(totalValue, format: .usd)
                    .font(.largeTitle)
                    .bold()
            }
            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: profitLoss >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption)
                    Text("\(profitLoss, format: .usd) (\(profitLossPercentage / 100, format: .percentChange))")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(profitLoss >= 0 ? .green : .red)
                
                Text("Total Invested: \(totalInvestment, format: .usd)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PortfolioSummaryView(totalValue: 20, totalInvestment: 200, profitLoss: 2, profitLossPercentage: 12)
}
