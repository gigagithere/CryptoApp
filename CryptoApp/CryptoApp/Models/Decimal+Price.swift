//
//  Decimal+Price.swift
//  CryptoApp
//

import Foundation

nonisolated extension Decimal {
    /// Converts an API `Double` to `Decimal` through its shortest decimal representation.
    ///
    /// `Decimal(0.1)` carries the binary noise of the `Double` (0.1000000000000000055…),
    /// which would leak into stored purchase prices and profit/loss maths.
    /// `Decimal(price: 0.1)` is exactly 0.1.
    init(price: Double) {
        guard price.isFinite else {
            self = 0
            return
        }
        self = Decimal(string: "\(price)", locale: Locale(identifier: "en_US_POSIX")) ?? Decimal(price)
    }

    /// For chart APIs that only take `Double`. Don't use it for money maths.
    var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
    }
}
