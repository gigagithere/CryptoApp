//
//  PortfolioChartView.swift
//  CryptoApp
//
//  The portfolio distribution card: a pie, a legend, and an expanded view with all coins
//

import SwiftUI

struct PortfolioChartView: View {
    @Environment(PortfolioViewModel.self) private var portfolio
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isExpanded = false
    
    var body: some View {
        let chartData = portfolio.distribution()
        let total = chartData.reduce(0) { $0 + $1.value }
        
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: Spacing.l) {
                HStack {
                    Text("Portfolio Distribution")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(chartData.count) coins")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical, Spacing.xs)
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: Radius.small))
                    
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                
                if chartData.isEmpty {
                    ContentUnavailableView("No data to display", systemImage: "chart.pie")
                        .frame(height: 200)
                } else {
                    // Side by side normally; stacked when large text would squeeze the legend
                    let layout = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: Spacing.xl))
                                                                     : AnyLayout(HStackLayout(spacing: Spacing.xl))
                    layout {
                        PieChart(data: chartData, size: 100)
                        ChartLegend(data: chartData, maxItems: 3)
                    }
                    
                    if isExpanded {
                        VStack(spacing: Spacing.m) {
                            Divider()
                            
                            if chartData.count > 3 {
                                Text("Additional Holdings")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ChartLegend(data: Array(chartData.dropFirst(3)), maxItems: chartData.count)
                            } else {
                                Text("All holdings are shown above")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Spacing.s)
                            }
                            
                            Divider()
                            
                            HStack {
                                LabeledValue(title: "Portfolio Summary") {
                                    Text("Total: \(total, format: .usdAmount)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                Spacer()
                                
                                LabeledValue(title: "Diversification", alignment: .trailing) {
                                    Text("\(chartData.count) different coins")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding(.top, Spacing.s)
                        }
                        .transition(.slide)
                    } else if chartData.count > 3 {
                        Text("+\(chartData.count - 3) more coins")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(Spacing.l)
            .card(radius: Radius.large, elevated: true)
        }
        .buttonStyle(.plain)
        .accessibilityHint(isExpanded ? "Shows fewer coins" : "Shows all coins")
    }
}

#Preview {
    PortfolioChartView()
        .padding()
        .previewEnvironment()
}
