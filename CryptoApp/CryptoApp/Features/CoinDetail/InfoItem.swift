//
//  InfoItem.swift
//  CryptoApp
//

import Foundation

/// One statistic on the coin detail screen.
struct InfoItem: Identifiable {
    let title: String
    let value: String
    var footnote: String?

    var id: String { title }
}
