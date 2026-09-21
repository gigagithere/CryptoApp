//
//  PieChart.swift
//  CryptoApp
//
//  Reusable pie chart component
//

import SwiftUI

struct PieChart: View {
    let data: [DistributionData]
    let size: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                PieSlice(
                    startAngle: .degrees(startAngleForIndex(index)),
                    endAngle: .degrees(endAngleForIndex(index))
                )
                .fill(Color.coin(item.coinSymbol))
                .opacity(0.8)
            }
        }
        .frame(width: size, height: size)
        .fixedSize()
    }
    
    private func startAngleForIndex(_ index: Int) -> Double {
        let totalValue = data.reduce(0) { $0 + $1.value }
        var cumulativeAngle: Double = 0
        
        for i in 0..<index {
            cumulativeAngle += (data[i].value / totalValue) * 360
        }
        
        return cumulativeAngle
    }
    
    private func endAngleForIndex(_ index: Int) -> Double {
        let totalValue = data.reduce(0) { $0 + $1.value }
        var cumulativeAngle: Double = 0
        
        for i in 0...index {
            cumulativeAngle += (data[i].value / totalValue) * 360
        }
        
        return cumulativeAngle
    }
}
