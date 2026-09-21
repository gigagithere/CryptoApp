//
//  ChartView.swift
//  CryptoApp
//
//  📈INTERACTIVE 7-DAY PRICE CHART 
//  Custom chart component with touch interaction and gradient fill
//  Displays sparkline data from CoinGecko API
//
//  Created by Bartosz Mrugała on 18/03/2025.
//

import SwiftUI

// MARK: - Interactive Chart Component

/// 📈 Interactive 7-day price chart with touch selection and animated rendering
struct CoinDetailChartView: View {
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    private let lineColor: Color
    private let startingDate: Date
    private let endingDate: Date

    @State private var percentage: CGFloat = 0
    @State private var selectedValue: Double? = nil

    init(coin: Coin) {
        data = coin.sparklineIn7D?.price ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0

        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        lineColor = priceChange >= 0 ? Color.green : Color.red

        if let lastUpdated = coin.lastUpdated, !lastUpdated.isEmpty {
            endingDate = Date(coinGeckoString: lastUpdated)
        } else {
            endingDate = Date()
        }
        startingDate = endingDate.addingTimeInterval(-7 * 24 * 60 * 60)
    }

    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No data available")
                    .frame(height: 200)
            } else {
                chartView
                    .frame(height: 200)
                    .background(chartBackground)
                    .overlay(chartYAxis.padding(.horizontal, 4), alignment: .leading)
            }
            chartDateLabels
                .padding(.horizontal, 4)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .onAppear {
                    percentage = 1.0
        }
    }
}

// MARK: - Chart Rendering

extension CoinDetailChartView {
    /// 🎨 Main chart rendering with interactive touch gestures
    private var chartView: some View {
        GeometryReader { geometry in
            ZStack {
                // Create chart line path
                let linePath = Path { path in
                    for index in data.indices {
                        let xPosition = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                        let yAxisRange = maxY - minY
                        let yPosition = (1 - CGFloat((data[index] - minY) / yAxisRange)) * geometry.size.height
                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                }
                
                // Draw chart line with animation
                linePath
                    .trim(from: 0, to: percentage)
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                
                // Create gradient fill area under chart
                let fillPath = Path { path in
                    // Draw same path as line
                    for index in data.indices {
                        let xPosition = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                        let yAxisRange = maxY - minY
                        let yPosition = (1 - CGFloat((data[index] - minY) / yAxisRange)) * geometry.size.height
                        if index == 0 {
                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                        } else {
                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                        }
                    }
                    // Close path to bottom edge for gradient fill
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.closeSubpath()
                }
                
                // Fill with gradient from top to bottom
                fillPath
                    .trim(from: 0, to: percentage)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [lineColor.opacity(0.3), lineColor.opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Interactive touch selection overlay
                if let selectedValue = selectedValue {
                    if let index = data.firstIndex(of: selectedValue) {
                        let xPosition = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                        let yAxisRange = maxY - minY
                        let yPosition = (1 - CGFloat((data[index] - minY) / yAxisRange)) * geometry.size.height
                        
                        Path { path in
                            path.move(to: CGPoint(x: xPosition, y: 0))
                            path.addLine(to: CGPoint(x: xPosition, y: geometry.size.height))
                        }
                        .stroke(Color.gray, lineWidth: 1)
                        
                        Text(String(format: "%.2f", selectedValue))
                            .padding(5)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                            .position(x: xPosition, y: yPosition)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let xValue = value.location.x
                        let computedIndex = Int((xValue / geometry.size.width) * CGFloat(data.count))
                        if computedIndex >= 0 && computedIndex < data.count {
                            selectedValue = data[computedIndex]
                        }
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                selectedValue = nil
                            }
                        }
                    }
            )
        }
    }

    private var chartBackground: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }

    private var chartYAxis: some View {
        VStack {
            Text(formatYAxisValue(maxY))
            Spacer()
            Text(formatYAxisValue((maxY + minY) / 2))
            Spacer()
            Text(formatYAxisValue(minY))
        }
    }
    
    private func formatYAxisValue(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fK", value / 1_000)
        } else if value >= 1 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.4f", value)
        }
    }

    private var chartDateLabels: some View {
        HStack {
            Text(startingDate.asShortDateString())
            Spacer()
            Text(endingDate.asShortDateString())
        }
    }
}

#Preview {
    CoinDetailChartView(coin: Coin.sample)
}
