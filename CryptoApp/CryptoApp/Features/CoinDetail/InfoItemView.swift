//
//  InfoItemView.swift
//  CryptoApp
//
//  Reusable component for displaying coin information items
//

import SwiftUI

struct InfoItemView: View {
    let title: LocalizedStringKey
    let value: String
    let footnote: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .secondaryText()
            
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            if let footnote = footnote {
                Text(footnote)
                    .secondaryText()
            }
        }
        // Stretch before the card is drawn, so tiles in one grid row end up equally tall
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.vertical, Spacing.s)
        .padding(.horizontal, Spacing.m)
        .card(radius: Radius.small)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: Spacing.l) {
        InfoItemView(
            title: "Current Price",
            value: "$42,150.00",
            footnote: "+2.45%"
        )
        
        InfoItemView(
            title: "Market Cap",
            value: "$825.4B",
            footnote: "+1.23%"
        )
        
        InfoItemView(
            title: "Rank",
            value: "#1",
            footnote: nil
        )
    }
    .padding()
}