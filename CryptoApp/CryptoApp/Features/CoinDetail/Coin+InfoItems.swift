//
//  Coin+InfoItems.swift
//  CryptoApp
//
//  The statistics shown on the coin detail screen, already formatted.
//

import Foundation

extension Coin {
    var overviewItems: [InfoItem] {
        [
            InfoItem(title: "Current Price",
                     value: currentPrice.formatted(.usd),
                     footnote: (priceChangePercentage24H / 100).formatted(.percentChangeSigned)),
            InfoItem(title: "Market Capitalization",
                     value: (marketCap ?? 0).formatted(.compact),
                     footnote: ((marketCapChangePercentage24H ?? 0) / 100).formatted(.percentChangeSigned)),
            InfoItem(title: "Rank",
                     value: marketCapRank.formatted()),
            InfoItem(title: "Volume",
                     value: (totalVolume ?? 0).formatted(.compact),
                     footnote: "data not available")
        ]
    }

    var additionalItems: [InfoItem] {
        [
            InfoItem(title: "ATH",
                     value: (ath ?? 0).formatted(.usd),
                     footnote: Self.shortDate(athDate)),
            InfoItem(title: "ATL",
                     value: (atl ?? 0).formatted(.usd),
                     footnote: Self.shortDate(atlDate)),
            InfoItem(title: "Circulating Supply",
                     value: (circulatingSupply ?? 0).formatted(.compact),
                     footnote: symbol.uppercased()),
            InfoItem(title: "Max Supply",
                     value: maxSupply?.formatted(.compact) ?? "No Limit",
                     footnote: maxSupply != nil ? symbol.uppercased() : nil)
        ]
    }

    var marketStatisticItems: [InfoItem] {
        [
            InfoItem(title: "24h High",
                     value: (high24H ?? 0).formatted(.usd),
                     footnote: "Daily Peak"),
            InfoItem(title: "24h Low",
                     value: (low24H ?? 0).formatted(.usd),
                     footnote: "Daily Low"),
            InfoItem(title: "Price Change",
                     value: priceChange24H.formatted(.usdChange),
                     footnote: (priceChangePercentage24H / 100).formatted(.percentChangeSigned)),
            InfoItem(title: "Market Cap Change",
                     value: (marketCapChange24H ?? 0).formatted(.compact),
                     footnote: ((marketCapChangePercentage24H ?? 0) / 100).formatted(.percentChangeSigned))
        ]
    }

    /// A CoinGecko timestamp as a short local date; the raw text if it can't be parsed.
    private static func shortDate(_ timestamp: String?) -> String? {
        timestamp.map { Date.fromCoinGecko($0)?.formatted(date: .numeric, time: .omitted) ?? $0 }
    }
}
