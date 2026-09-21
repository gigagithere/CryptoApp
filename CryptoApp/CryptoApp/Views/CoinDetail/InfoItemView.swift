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
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .secondaryText()
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if let footnote = footnote {
                Text(footnote)
                    .secondaryText()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    VStack(spacing: 16) {
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