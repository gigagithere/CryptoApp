//
//  Coin.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import Foundation

struct Coin: Codable, Identifiable, Equatable {
    let id, symbol, name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int
    let fullyDilutedValuation: Double?
    let totalVolume, high24H, low24H: Double?
    let priceChange24H, priceChangePercentage24H: Double
    let marketCapChange24H: Double?
    let marketCapChangePercentage24H: Double?
    let circulatingSupply, totalSupply, maxSupply, ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl, atlChangePercentage: Double?
    let atlDate: String?
    let lastUpdated: String?
    let sparklineIn7D: SparklineIn7D?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case sparklineIn7D = "sparkline_in_7d"
    }
}

    extension Coin {
        static var sample = Coin(
            id: "bitcoin",
            symbol: "BTC",
            name: "Bitcoin",
            image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            currentPrice: 16700,
            marketCap: 320000000000.0,
            marketCapRank: 1,
            fullyDilutedValuation: 350000000000.0,
            totalVolume: 25000000000.0,
            high24H: 17000,
            low24H: 16500,
            priceChange24H: 200,
            priceChangePercentage24H: 1.2,
            marketCapChange24H: 5000000000.0,
            marketCapChangePercentage24H: 1.5,
            circulatingSupply: 19000000,
            totalSupply: 21000000,
            maxSupply: 21000000,
            ath: 69000,
            athChangePercentage: -75.7,
            athDate: "2021-11-10T00:00:00.000Z",
            atl: 67.81,
            atlChangePercentage: 24570.0,
            atlDate: "2013-07-06T00:00:00.000Z",
            lastUpdated: "2024-08-26T12:00:00.000Z",
            sparklineIn7D: SparklineIn7D(price: [33.445, 35.555, 34.484, 36.666, 35.485, 34.233, 36.222, 22.444, 25.555, 20.222, 5.222])
        )
    }

struct SparklineIn7D: Codable, Equatable {
    let price: [Double]?
}

    

