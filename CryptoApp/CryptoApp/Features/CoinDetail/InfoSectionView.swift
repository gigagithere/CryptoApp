//
//  InfoSectionView.swift
//  CryptoApp
//

import SwiftUI

/// A titled block of statistics, laid out in two columns.
struct InfoSectionView: View {
    let title: String
    let items: [InfoItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            Divider()

            // Two tiles per row; both tiles in a row are as tall as the taller one
            let rows = stride(from: 0, to: items.count, by: 2).map { Array(items[$0..<min($0 + 2, items.count)]) }
            Grid(horizontalSpacing: 15, verticalSpacing: 15) {
                ForEach(rows.indices, id: \.self) { index in
                    GridRow {
                        ForEach(rows[index]) { item in
                            InfoItemView(title: item.title, value: item.value, footnote: item.footnote)
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

#Preview {
    InfoSectionView(title: "Overview", items: [
        InfoItem(title: "Current Price", value: "$42,150.00", footnote: "+2.45%"),
        InfoItem(title: "Rank", value: "1"),
        InfoItem(title: "Volume", value: "1.2B")
    ])
}
