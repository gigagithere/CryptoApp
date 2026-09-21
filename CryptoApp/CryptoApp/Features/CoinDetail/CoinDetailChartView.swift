//
//  CoinDetailChartView.swift
//  CryptoApp
//
//  Interactive 7-day price chart built from CoinGecko's sparkline data.
//
//  Created by Bartosz Mrugała on 18/03/2025.
//

import SwiftUI
import Charts

struct CoinDetailChartView: View {
    private struct Point: Identifiable {
        let date: Date
        let price: Double
        var id: Date { date }
    }

    private let points: [Point]
    private let lineColor: Color
    /// Fitted to the data, so a week of small moves isn't squashed against a zero baseline
    private let yDomain: ClosedRange<Double>

    /// The date under the user's finger while dragging on the chart
    @State private var selectedDate: Date?

    init(coin: Coin) {
        let prices = coin.sparklineIn7D?.price ?? []
        let week: TimeInterval = 7 * 24 * 60 * 60
        let end = coin.lastUpdated.flatMap(Date.fromCoinGecko) ?? .now
        let step = prices.count > 1 ? week / Double(prices.count - 1) : 0

        // CoinGecko gives one price per hour and no timestamps: spread them evenly over the week
        points = prices.enumerated().map { index, price in
            Point(date: end.addingTimeInterval(-week + Double(index) * step), price: price)
        }
        lineColor = (prices.last ?? 0) >= (prices.first ?? 0) ? .green : .red

        let low = prices.min() ?? 0
        let high = prices.max() ?? 1
        let padding = high > low ? (high - low) * 0.05 : max(abs(high) * 0.01, 0.01) // flat data still needs a range
        yDomain = (low - padding)...(high + padding)
    }

    /// The point closest to the finger
    private var selectedPoint: Point? {
        guard let selectedDate else { return nil }
        return points.min { abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate)) }
    }

    var body: some View {
        if points.count < 2 {
            Text("No data available")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(height: 200)
        } else {
            chart
        }
    }

    private var chart: some View {
        Chart {
            ForEach(points) { point in
                AreaMark(x: .value("Date", point.date),
                         yStart: .value("Base", yDomain.lowerBound),
                         yEnd: .value("Price", point.price))
                    .foregroundStyle(.linearGradient(colors: [lineColor.opacity(0.3), lineColor.opacity(0)],
                                                     startPoint: .top, endPoint: .bottom))
                LineMark(x: .value("Date", point.date), y: .value("Price", point.price))
                    .foregroundStyle(lineColor)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }

            if let selectedPoint {
                RuleMark(x: .value("Date", selectedPoint.date))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    // Negative spacing pulls the label down into the top of the plot, so it doesn't cover the screen title above
                    .annotation(position: .top, spacing: -44, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        // A solid fill on purpose: a material has nothing to blur in a chart annotation and shows up black
                        VStack(spacing: 2) {
                            Text(selectedPoint.price, format: .usd)
                                .bold()
                            // The sparkline has no timestamps, so the time is approximate (one price per hour)
                            Text(selectedPoint.date, format: .dateTime.day().month(.abbreviated).hour().minute())
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical, Spacing.xs)
                        .background(.background.secondary, in: .rect(cornerRadius: Radius.small))
                        .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                    }

                PointMark(x: .value("Date", selectedPoint.date), y: .value("Price", selectedPoint.price))
                    .foregroundStyle(lineColor)
            }
        }
        .chartYScale(domain: yDomain)
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let price = value.as(Double.self) {
                        Text(price, format: .number.notation(.compactName).precision(.significantDigits(3)))
                    }
                }
            }
        }
        .frame(height: 200)
        .padding(.horizontal, Spacing.xs)
        .accessibilityLabel("7 day price chart")
        .accessibilityValue("From \((points.first?.price ?? 0).formatted(.usd)) to \((points.last?.price ?? 0).formatted(.usd)), low \(yDomain.lowerBound.formatted(.usd)), high \(yDomain.upperBound.formatted(.usd))")
    }
}

#Preview {
    CoinDetailChartView(coin: Coin.sample)
}
