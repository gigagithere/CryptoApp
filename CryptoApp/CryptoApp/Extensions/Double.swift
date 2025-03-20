//
//  Double.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import Foundation

extension Double {
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    func toCurrency() -> String {
        currencyFormatter.string(for: self) ?? "$0.00"
    }
    
    func toPercentString() -> String {
        (numberFormatter.string(for: self) ?? "") + "%"
    }
    
    func toAbbreviatedString() -> String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        
        switch absValue {
        case 1_000_000_000_000...:
            let fraction = absValue / 1_000_000_000_000
            return "\(sign)\(numberFormatter.string(for: fraction) ?? "\(fraction)")Tr"
        case 1_000_000_000...:
            let fraction = absValue / 1_000_000_000
            return "\(sign)\(numberFormatter.string(for: fraction) ?? "\(fraction)")B"
        case 1_000_000...:
            let fraction = absValue / 1_000_000
            return "\(sign)\(numberFormatter.string(for: fraction) ?? "\(fraction)")M"
        case 1_000...:
            let fraction = absValue / 1_000
            return "\(sign)\(numberFormatter.string(for: fraction) ?? "\(fraction)")K"
        default:
            return "\(sign)\(numberFormatter.string(for: absValue) ?? "\(absValue)")"
        }
    }
}
