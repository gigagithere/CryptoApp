//
//  DistributionData.swift
//  CryptoApp
//
//  Portfolio distribution data model and calculator
//

import Foundation

struct DistributionData {
    let coinSymbol: String
    let value: Double
    let percentage: Double
}

struct DistributionCalculator {
    @MainActor
    static func calculate(from holdings: [Holding], portfolioViewModel: any PortfolioViewModelProtocol) -> [DistributionData] {
        let dataWithoutPercentage = holdings.compactMap { holding -> DistributionData? in
            let currentPrice = portfolioViewModel.getCurrentPrice(for: holding.coinId) ?? holding.averagePurchasePrice
            let currentValue = holding.quantity * currentPrice
            
            return DistributionData(
                coinSymbol: holding.coinSymbol.uppercased(),
                value: currentValue.doubleValue,
                percentage: 0 // Will be calculated below
            )
        }
        .sorted { $0.value > $1.value }
        
        let totalValue = dataWithoutPercentage.reduce(0.0) { $0 + $1.value }
        
        return dataWithoutPercentage.map { data in
            let percentage = totalValue > 0 ? (data.value / totalValue) * 100 : 0
            
            return DistributionData(
                coinSymbol: data.coinSymbol,
                value: data.value,
                percentage: percentage
            )
        }
    }
}