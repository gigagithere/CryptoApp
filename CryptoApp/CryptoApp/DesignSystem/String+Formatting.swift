//
//  String.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 18/03/2025.
//

import Foundation

extension String {
    /// A CoinGecko timestamp shown as a short local date; falls back to the raw string if it can't be parsed.
    var asFormattedDate: String {
        guard let date = Date.fromCoinGecko(self) else { return self }
        return date.asShortDateString()
    }
}
