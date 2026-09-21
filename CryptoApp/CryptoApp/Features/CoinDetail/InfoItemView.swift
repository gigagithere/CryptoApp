//
//  InfoItemView.swift
//  CryptoApp
//
//  Reusable component for displaying coin information items
//

import SwiftUI

struct InfoItemView: View {
    let title: String
    let value: String
    let footnote: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .secondaryText()
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            if let footnote = footnote {
                Text(footnote)
                    .secondaryText()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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