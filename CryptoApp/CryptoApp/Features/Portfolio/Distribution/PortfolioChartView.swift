//
//  PortfolioChartView.swift
//  CryptoApp
//
//  The portfolio distribution card: a pie, a legend, and an expanded view with all coins
//

import SwiftUI

struct PortfolioChartView: View {
    @Environment(PortfolioViewModel.self) private var portfolio
    @State private var isExpanded = false
    
    var body: some View {
        let chartData = portfolio.distribution()
        let total = chartData.reduce(0) { $0 + $1.value }
        
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Portfolio Distribution")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(chartData.count) coins")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 8))
                    
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                
                if chartData.isEmpty {
                    ContentUnavailableView("No data to display", systemImage: "chart.pie")
                        .frame(height: 200)
                } else {
                    HStack(spacing: 20) {
                        PieChart(data: chartData, size: 100)
                        ChartLegend(data: chartData, maxItems: 3)
                    }
                    
                    if isExpanded {
                        VStack(spacing: 12) {
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
                                    .padding(.vertical, 8)
                            }
                            
                            Divider()
                            
                            HStack {
                                LabeledValue(title: "Portfolio Summary") {
                                    Text("Total: \(total, format: .usd)")
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
                            .padding(.top, 8)
                        }
                        .transition(.slide)
                    } else if chartData.count > 3 {
                        Text("+\(chartData.count - 3) more coins")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PortfolioChartView()
        .padding()
        .previewEnvironment()
}
