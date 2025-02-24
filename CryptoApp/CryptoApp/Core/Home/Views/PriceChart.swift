//
//  PriceChart.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 31/01/2025.
//

import SwiftUI
import Charts

struct PriceChart: View {
    let priceHistory: [(time: Date, price: Double)]

    var body: some View {
        Chart {
            ForEach(priceHistory, id: \.time) { dataPoint in
                LineMark(
                    x: .value("Time", dataPoint.time),
                    y: .value("Price", dataPoint.price)
                )
            }
        }
        .frame(height: 300)
    }
}
