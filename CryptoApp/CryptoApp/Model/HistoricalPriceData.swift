//
//  HistoricalPriceData.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 31/01/2025.
//

import Foundation
import Foundation

struct HistoricalPriceData: Codable {
    let prices: [[Double]] // [timestamp, price]
    let market_caps: [[Double]]? // [timestamp, market_cap]
    let total_volumes: [[Double]]? // [timestamp, volume]
}
