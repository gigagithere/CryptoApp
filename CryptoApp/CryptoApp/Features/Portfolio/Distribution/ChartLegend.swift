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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(data.prefix(maxItems), id: \.coinSymbol) { item in
                VStack(spacing: 6) {
                    HStack(spacing: Spacing.m) {
                        Circle()
                            .fill(Color.coin(item.coinSymbol))
                            .frame(width: 14, height: 14)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.coinSymbol)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(item.percentage / 100, format: .percentChange)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(item.value, format: .usdAmount)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    ProgressView(value: item.percentage, total: 100)
                        .tint(Color.coin(item.coinSymbol))
                }
                .padding(.vertical, 3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ChartLegend(data: [
        DistributionData(coinSymbol: "BTC", value: 3000, percentage: 60),
        DistributionData(coinSymbol: "ETH", value: 2000, percentage: 40)
    ], maxItems: 3)
    .padding()
}
