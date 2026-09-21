//
//  DistributionData.swift
//  CryptoApp
//
//  One slice of the portfolio distribution chart (built by `PortfolioViewModel.distribution()`)
//

import Foundation

struct DistributionData {
    let coinSymbol: String
    let value: Double
    let percentage: Double
}
