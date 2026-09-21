//
//  PortfolioLinkRow.swift
//  CryptoApp
//

import SwiftUI

/// A tappable card on the portfolio screen that opens a detail page.
struct PortfolioLinkRow: View {
    let title: String
    let subtitle: String
    let route: Route

    var body: some View {
        NavigationLink(value: route) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .headlineText()
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .secondaryText()
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .secondaryText()
            }
            .cardStyle()
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PortfolioLinkRow(title: "Current Holdings", subtitle: "2 holdings", route: .holdings)
            .padding()
    }
}
