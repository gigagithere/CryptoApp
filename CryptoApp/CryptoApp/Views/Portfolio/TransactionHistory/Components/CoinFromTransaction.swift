//
//  CoinFromTransaction.swift
//  CryptoApp
//
//  Creates Coin object from Transaction data
//

import Foundation

extension Transaction {
    func toCoin(currentPrice: Decimal) -> Coin {
        let priceDouble = currentPrice.doubleValue
        return Coin(
            id: coinId,
            symbol: coinSymbol,
            name: coinSymbol.uppercased(),
            image: imageUrl,
            currentPrice: priceDouble,
            marketCap: nil,
            marketCapRank: 0,
            fullyDilutedValuation: nil,
            totalVolume: nil,
            high24H: nil,
            low24H: nil,
            priceChange24H: 0.0,
            priceChangePercentage24H: 0.0,
            marketCapChange24H: nil,
            marketCapChangePercentage24H: nil,
            circulatingSupply: nil,
            totalSupply: nil,
            maxSupply: nil,
            ath: nil,
            athChangePercentage: 0.0,
            athDate: nil,
            atl: nil,
            atlChangePercentage: nil,
            atlDate: nil,
            lastUpdated: nil,
            sparklineIn7D: nil
        )
    }
}