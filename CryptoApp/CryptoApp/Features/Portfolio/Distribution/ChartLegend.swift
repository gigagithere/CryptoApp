//
//  ChartLegend.swift
//  CryptoApp
//
//  Portfolio chart legend component
//

import SwiftUI

struct ChartLegend: View {
    let data: [DistributionData]
    let maxItems: Int
    let colorForCoin: (String) -> Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(data.prefix(maxItems), id: \.coinSymbol) { item in
                legendItem(for: item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func legendItem(for item: DistributionData) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 12) {
                Circle()
                    .fill(colorForCoin(item.coinSymbol))
                    .frame(width: 14, height: 14)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.coinSymbol)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("\(String(format: "%.2f", item.percentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(Decimal(item.value).asCurrencyString())
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            // Progress Bar
            GeometryReader { geometry in
                HStack {
                    Rectangle()
                        .fill(colorForCoin(item.coinSymbol))
                        .frame(width: geometry.size.width * (item.percentage / 100))
                        .frame(height: 3)
                        .clipShape(Capsule())

                    Spacer(minLength: 0)
                }
            }
            .frame(height: 3)
        }
        .padding(.vertical, 3)
    }
}