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

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 15), GridItem(.flexible())], spacing: 15) {
                ForEach(items) { item in
                    InfoItemView(title: item.title, value: item.value, footnote: item.footnote)
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
