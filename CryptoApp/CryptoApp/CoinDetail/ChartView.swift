//
//  ChartView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 18/03/2025.
//

import SwiftUI

struct ChartView: View {
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
                Text("Brak danych")
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

extension ChartView {
    private var chartView: some View {
        GeometryReader { geometry in
            ZStack {
                // Tworzymy ścieżkę wykresu (linia)
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
                
                // Rysujemy linię wykresu (bez cienia)
                linePath
                    .trim(from: 0, to: percentage)
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                
                // Tworzymy ścieżkę obszaru pod wykresem
                let fillPath = Path { path in
                    // Rysujemy wykres (tak jak linia)
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
                    // Dodajemy linie do dolnej krawędzi wykresu
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.closeSubpath()
                }
                
                // Wypełniamy obszar gradientem, który rozciąga się od górnej do dolnej krawędzi całego wykresu
                fillPath
                    .trim(from: 0, to: percentage)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [lineColor.opacity(0.3), lineColor.opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Rysujemy interaktywne elementy (pionowa linia i etykieta) – pozostawiamy bez zmian
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
            Text(maxY.formatted(.number.precision(.fractionLength(2)))) + Text("K")
            Spacer()
            Text(((maxY + minY) / 2).formatted(.number.precision(.fractionLength(2)))) + Text("K")
            Spacer()
            Text(minY.formatted(.number.precision(.fractionLength(2)))) + Text("K")
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
    ChartView(coin: Coin.sample)
}
