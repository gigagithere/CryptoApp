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
    let totalVolume: Double?
    let high24H: Double?
    let low24H: Double?
    let priceChange24H: Double
    let priceChangePercentage24H: Double
    let marketCapChange24H: Double?
    let marketCapChangePercentage24H: Double?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double?
    let athChangePercentage: Double
    let athDate: String?
    let atl: Double?
    let atlChangePercentage: Double?
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

struct SparklineIn7D: Codable, Equatable {
    let price: [Double]?
}

// Defined in an extension so the memberwise initializer stays available.
// CoinGecko occasionally returns null for these fields (e.g. brand-new listings),
// which would otherwise make decoding of the whole coin list fail.
extension Coin {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        symbol = try c.decode(String.self, forKey: .symbol)
        name = try c.decode(String.self, forKey: .name)
        image = try c.decode(String.self, forKey: .image)
        currentPrice = try c.decode(Double.self, forKey: .currentPrice)
        marketCap = try c.decodeIfPresent(Double.self, forKey: .marketCap)
        marketCapRank = try c.decodeIfPresent(Int.self, forKey: .marketCapRank) ?? 0
        fullyDilutedValuation = try c.decodeIfPresent(Double.self, forKey: .fullyDilutedValuation)
        totalVolume = try c.decodeIfPresent(Double.self, forKey: .totalVolume)
        high24H = try c.decodeIfPresent(Double.self, forKey: .high24H)
        low24H = try c.decodeIfPresent(Double.self, forKey: .low24H)
        priceChange24H = try c.decodeIfPresent(Double.self, forKey: .priceChange24H) ?? 0
        priceChangePercentage24H = try c.decodeIfPresent(Double.self, forKey: .priceChangePercentage24H) ?? 0
        marketCapChange24H = try c.decodeIfPresent(Double.self, forKey: .marketCapChange24H)
        marketCapChangePercentage24H = try c.decodeIfPresent(Double.self, forKey: .marketCapChangePercentage24H)
        circulatingSupply = try c.decodeIfPresent(Double.self, forKey: .circulatingSupply)
        totalSupply = try c.decodeIfPresent(Double.self, forKey: .totalSupply)
        maxSupply = try c.decodeIfPresent(Double.self, forKey: .maxSupply)
        ath = try c.decodeIfPresent(Double.self, forKey: .ath)
        athChangePercentage = try c.decodeIfPresent(Double.self, forKey: .athChangePercentage) ?? 0
        athDate = try c.decodeIfPresent(String.self, forKey: .athDate)
        atl = try c.decodeIfPresent(Double.self, forKey: .atl)
        atlChangePercentage = try c.decodeIfPresent(Double.self, forKey: .atlChangePercentage)
        atlDate = try c.decodeIfPresent(String.self, forKey: .atlDate)
        lastUpdated = try c.decodeIfPresent(String.self, forKey: .lastUpdated)
        sparklineIn7D = try c.decodeIfPresent(SparklineIn7D.self, forKey: .sparklineIn7D)
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

