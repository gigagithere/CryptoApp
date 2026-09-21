//
//  Date+CoinGecko.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 18/03/2025.
//

import Foundation

extension Date {
    /// Parses CoinGecko timestamps such as `2025-11-02T14:03:21.123Z` (fractional seconds are optional).
    static func fromCoinGecko(_ string: String) -> Date? {
        (try? Date(string, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)))
            ?? (try? Date(string, strategy: Date.ISO8601FormatStyle()))
    }
}
