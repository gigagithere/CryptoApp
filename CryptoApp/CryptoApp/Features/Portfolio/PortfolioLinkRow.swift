//
//  PortfolioLinkRow.swift
//  CryptoApp
//

import SwiftUI

/// A tappable card on the portfolio screen that opens a detail page.
struct PortfolioLinkRow: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let route: Route

    var body: some View {
        NavigationLink(value: route) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
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
            .padding()
            .card()
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
