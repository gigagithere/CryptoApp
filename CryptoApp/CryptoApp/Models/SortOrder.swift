//
//  SortOrder.swift
//  CryptoApp
//

import SwiftUI

enum SortOrder: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"

    var title: LocalizedStringKey {
        switch self {
        case .ascending: "Ascending"
        case .descending: "Descending"
        }
    }
}
