//
//  DecimalPriceTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

struct DecimalPriceTests {
    @Test(arguments: [
        (0.1, "0.1"),
        (85688.12, "85688.12"),
        (0.9997, "0.9997"),
        (2734.94, "2734.94")
    ])
    func convertsWithoutBinaryNoise(value: Double, expected: String) throws {
        let exact = try #require(Decimal(string: expected, locale: Locale(identifier: "en_US_POSIX")))
        
        #expect(Decimal(price: value) == exact)
    }
    
    @Test func nonFiniteValuesBecomeZero() {
        #expect(Decimal(price: .nan) == 0)
        #expect(Decimal(price: .infinity) == 0)
    }
    
    @Test func tinyPricesKeepTheirValue() throws {
        // Swift prints these in scientific notation ("1.234e-05")
        let exact = try #require(Decimal(string: "0.00001234", locale: Locale(identifier: "en_US_POSIX")))
        
        #expect(Decimal(price: 0.00001234) == exact)
    }
}
