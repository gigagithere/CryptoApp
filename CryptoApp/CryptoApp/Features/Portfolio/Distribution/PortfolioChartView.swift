//
//  PortfolioChartView.swift
//  CryptoApp
//
//  Simplified portfolio chart using focused components
//

import SwiftUI

struct PortfolioChartView: View {
    @Environment(PortfolioViewModel.self) private var portfolio
    @State private var isExpanded = false
    
    private var chartData: [DistributionData] {
        portfolio.distribution()
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }) {
            VStack(alignment: .leading, spacing: 16) {
                header
                
                if chartData.isEmpty {
                    emptyState
                } else {
                    chartContent
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private var header: some View {
        HStack {
            Text("Portfolio Distribution")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("\(chartData.count) coins")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No data to display")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    private var chartContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                PieChart(data: chartData, size: 100)
                
                ChartLegend(
                    data: chartData,
                    maxItems: 3,
                    colorForCoin: Color.coin
                )
            }
            
            if !isExpanded && chartData.count > 3 {
                Text("+\(chartData.count - 3) more coins")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if isExpanded {
                expandedContent
            }
        }
    }
    
    private var expandedContent: some View {
        VStack(spacing: 12) {
            Divider()
            
            if chartData.count > 3 {
                Text("Additional Holdings")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ChartLegend(
                    data: Array(chartData.dropFirst(3)),
                    maxItems: chartData.count,
                    colorForCoin: Color.coin
                )
            } else {
                Text("All holdings are shown above")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
            
            Divider()
            
            summaryStats
        }
        .transition(.slide)
    }
    
    private var summaryStats: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Portfolio Summary")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Total: \(Decimal(chartData.reduce(0) { $0 + $1.value }).asCurrencyString())")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Diversification")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(chartData.count) different coins")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    PortfolioChartView()
        .padding()
        .background(Color(.systemBackground))
        .previewEnvironment()
}
