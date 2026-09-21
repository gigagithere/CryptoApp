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
                .fill(colorForCoin(item.coinSymbol))
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
    
    private func colorForCoin(_ symbol: String) -> Color {
        let colors: [Color] = [
            .blue, .green, .orange, .purple, .pink, .red, .yellow, .cyan, 
            .mint, .indigo, .teal, .brown, Color(red: 0.8, green: 0.2, blue: 0.6),
            Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.9, green: 0.6, blue: 0.1),
            Color(red: 0.3, green: 0.7, blue: 0.9), Color(red: 0.7, green: 0.3, blue: 0.8),
            Color(red: 0.1, green: 0.5, blue: 0.8), Color(red: 0.8, green: 0.4, blue: 0.2),
            Color(red: 0.5, green: 0.8, blue: 0.3)
        ]
        
        var hasher = Hasher()
        hasher.combine(symbol.uppercased())
        let hash = hasher.finalize()
        let index = abs(hash) % colors.count
        
        return colors[index]
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
