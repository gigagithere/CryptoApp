//
//  FormatStyleTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

/// The app's number formats, checked in an English locale so the expected text doesn't depend on the device.
struct FormatStyleTests {
    private let en = Locale(identifier: "en_US")

    // MARK: - Dollars

    @Test func priceKeepsUpToFourDecimals() {
        let style: Decimal.FormatStyle.Currency = .usd

        #expect(Decimal(string: "0.9023")!.formatted(style.locale(en)) == "$0.9023")
        #expect(Decimal(string: "1234.5")!.formatted(style.locale(en)) == "$1,234.50")
    }

    @Test func priceOfADoubleFromTheAPI() {
        let style: FloatingPointFormatStyle<Double>.Currency = .usd

        #expect(85_800.0.formatted(style.locale(en)) == "$85,800.00")
        #expect(0.0973.formatted(style.locale(en)) == "$0.0973")
    }

    @Test func totalsAreRoundedToCents() {
        let style: Decimal.FormatStyle.Currency = .usdAmount

        #expect(Decimal(string: "6759.4897")!.formatted(style.locale(en)) == "$6,759.49")
    }

    @Test func gainsAndLossesAlwaysShowASign() {
        let style: Decimal.FormatStyle.Currency = .usdChange

        #expect(Decimal(string: "25.8314")!.formatted(style.locale(en)) == "+$25.83")
        #expect(Decimal(-19).formatted(style.locale(en)) == "-$19.00")
    }

    // MARK: - Percentages (these take a fraction: pass percent / 100)

    @Test func percentChangeHasTwoDecimals() {
        let style: Decimal.FormatStyle.Percent = .percentChange

        #expect(Decimal(string: "0.0628")!.formatted(style.locale(en)) == "6.28%")
    }

    @Test func signedPercentChangeShowsPlusAndMinus() {
        let style: Decimal.FormatStyle.Percent = .percentChangeSigned

        #expect(Decimal(string: "0.0038")!.formatted(style.locale(en)) == "+0.38%")
        #expect(Decimal(string: "-0.0051")!.formatted(style.locale(en)) == "-0.51%")
    }

    @Test func signedPercentChangeOfADouble() {
        let style: FloatingPointFormatStyle<Double>.Percent = .percentChangeSigned

        #expect((5.81 / 100).formatted(style.locale(en)) == "+5.81%")
    }

    // MARK: - Quantities and big numbers

    @Test func quantityShowsUpToEightDecimalsWithoutTrailingZeros() {
        let style: Decimal.FormatStyle = .quantity

        #expect(Decimal(2).formatted(style.locale(en)) == "2")
        #expect(Decimal(string: "0.5")!.formatted(style.locale(en)) == "0.5")
        #expect(Decimal(string: "0.12345678")!.formatted(style.locale(en)) == "0.12345678")
        #expect(Decimal(string: "1.123456789")!.formatted(style.locale(en)) == "1.12345679")
    }

    @Test func compactNumbersUseShortSuffixes() {
        let style: FloatingPointFormatStyle<Double> = .compact

        #expect(1_230_000_000.0.formatted(style.locale(en)) == "1.23B")
        #expect(350_000_000.0.formatted(style.locale(en)) == "350M")
        #expect(5_300.0.formatted(style.locale(en)) == "5.3K")
        #expect(999.0.formatted(style.locale(en)) == "999")
    }
}
