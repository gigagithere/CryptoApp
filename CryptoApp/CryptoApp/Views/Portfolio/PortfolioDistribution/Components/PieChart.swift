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

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}
