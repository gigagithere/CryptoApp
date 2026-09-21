//
//  Decimal+Formatting.swift
//  CryptoApp
//
//  Created by Claude on 16/08/2025.
//

import Foundation

extension Decimal {
    /// Format as currency with dollar sign and appropriate decimal places
    func asCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4 // Balanced precision for readability
        
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }
    
    /// Format as number with appropriate decimal places for quantities
    func asQuantityString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8 // Crypto can have high precision
        
        return formatter.string(from: self as NSDecimalNumber) ?? "0"
    }
    
    /// Format as percentage with 2 decimal places
    func asPercentageString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        // Convert to percentage (divide by 100 since NumberFormatter multiplies by 100)
        let percentageValue = self / 100
        return formatter.string(from: percentageValue as NSDecimalNumber) ?? "0.00%"
    }
    
    /// Convert to Double for UI components that require it
    var doubleValue: Double {
        return (self as NSDecimalNumber).doubleValue
    }
    
    /// Format large numbers with abbreviations (1.2B, 350M, 5.3K)
    func asAbbreviatedString() -> String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        switch absValue {
        case 1_000_000_000_000...:
            let fraction = absValue / 1_000_000_000_000
            let fractionString = formatter.string(from: fraction as NSDecimalNumber) ?? "\(fraction)"
            return "\(sign)\(fractionString)Tr"
        case 1_000_000_000...:
            let fraction = absValue / 1_000_000_000
            let fractionString = formatter.string(from: fraction as NSDecimalNumber) ?? "\(fraction)"
            return "\(sign)\(fractionString)B"
        case 1_000_000...:
            let fraction = absValue / 1_000_000
            let fractionString = formatter.string(from: fraction as NSDecimalNumber) ?? "\(fraction)"
            return "\(sign)\(fractionString)M"
        case 1_000...:
            let fraction = absValue / 1_000
            let fractionString = formatter.string(from: fraction as NSDecimalNumber) ?? "\(fraction)"
            return "\(sign)\(fractionString)K"
        default:
            return formatter.string(from: absValue as NSDecimalNumber) ?? "\(absValue)"
        }
    }
}