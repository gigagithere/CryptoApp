//
//  PortfolioChartView.swift
//  CryptoApp
//
//  Simplified portfolio chart using focused components
//

import SwiftUI

struct PortfolioChartView: View {
    let holdings: [Holding]
    private var portfolioViewModel: any PortfolioViewModelProtocol
    @State private var isExpanded = false
    
    init(holdings: [Holding], portfolioViewModel: any PortfolioViewModelProtocol) {
        self.holdings = holdings
        self.portfolioViewModel = portfolioViewModel
    }
    
    private var chartData: [DistributionData] {
        DistributionCalculator.calculate(from: holdings, portfolioViewModel: portfolioViewModel)
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
                    colorForCoin: colorForCoin
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
                    colorForCoin: colorForCoin
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

#Preview {
    PortfolioChartView(
        holdings: [
            Holding(
                coinId: "bitcoin",
                coinSymbol: "BTC",
                quantity: 0.25,
                purchasePrice: 42000,
                date: Date().addingTimeInterval(-86400 * 15),
                imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
            ),
            Holding(
                coinId: "ethereum",
                coinSymbol: "ETH",
                quantity: 1.5,
                purchasePrice: 2800,
                date: Date().addingTimeInterval(-86400 * 12),
                imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"
            )
        ],
        portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService())
    )
    .padding()
    .background(Color(.systemBackground))
}
