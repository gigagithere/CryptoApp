//
//  SortEnums.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 19/03/2025.
//

import Foundation

enum SortOption: String, CaseIterable {
    case price = "Price"
    case marketCap = "Market Cap"
    case change = "24h Change"
    
    var iconName: String {
        switch self {
        case .price:
            return "dollarsign.circle"
        case .marketCap:
            return "chart.bar.fill"
        case .change:
            return "percent"
        }
    }
}

enum SortOrder: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
}
