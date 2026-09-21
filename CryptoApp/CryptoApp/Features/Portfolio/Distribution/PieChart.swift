//
//  PieChart.swift
//  CryptoApp
//

import SwiftUI
import Charts

/// A pie of the portfolio distribution, one colored slice per coin.
struct PieChart: View {
    let data: [DistributionData]
    let size: CGFloat

    var body: some View {
        Chart(data, id: \.coinSymbol) { item in
            SectorMark(angle: .value("Value", item.value))
                .foregroundStyle(Color.coin(item.coinSymbol))
                .opacity(0.8)
        }
        .chartLegend(.hidden)
        .frame(width: size, height: size)
    }
}

#Preview {
    PieChart(data: [
        DistributionData(coinSymbol: "BTC", value: 3000, percentage: 60),
        DistributionData(coinSymbol: "ETH", value: 2000, percentage: 40)
    ], size: 100)
}
