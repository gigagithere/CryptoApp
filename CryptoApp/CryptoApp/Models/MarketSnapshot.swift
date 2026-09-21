//
//  MarketSnapshot.swift
//  CryptoApp
//

import Foundation

/// The result of loading the market list: the coins plus whether they came from the offline cache.
struct MarketSnapshot {
    let coins: [Coin]
    let isFromCache: Bool
}
