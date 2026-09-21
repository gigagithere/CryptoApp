//
//  FormatStyles.swift
//  CryptoApp
//
//  The app's number formats, used directly in views:
//  `Text(price, format: .usd)`, `Text(quantity, format: .quantity)`,
//  `Text(change / 100, format: .percentChange)`, `marketCap.formatted(.compact)`.
//  They follow the device locale (comma decimals in Polish).
//

import Foundation

extension FormatStyle where Self == Decimal.FormatStyle.Currency {
    /// Dollars with 2 to 4 decimals, e.g. $1,234.50 or $0.9023
    static var usd: Self { .currency(code: "USD").precision(.fractionLength(2...4)) }
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Currency {
    static var usd: Self { .currency(code: "USD").precision(.fractionLength(2...4)) }
}

extension FormatStyle where Self == Decimal.FormatStyle {
    /// Coin amounts: up to 8 decimals, no trailing zeros. Crypto can be very fine-grained.
    static var quantity: Self { .number.precision(.fractionLength(0...8)) }
}

extension FormatStyle where Self == Decimal.FormatStyle.Percent {
    /// A fraction as a percentage with 2 decimals: pass `percent / 100`.
    static var percentChange: Self { .percent.precision(.fractionLength(2)) }
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Percent {
    static var percentChange: Self { .percent.precision(.fractionLength(2)) }
}

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
    /// Large numbers in short form: 1.2B, 350M, 5.3K
    static var compact: Self { .number.notation(.compactName).precision(.fractionLength(0...2)) }
}
