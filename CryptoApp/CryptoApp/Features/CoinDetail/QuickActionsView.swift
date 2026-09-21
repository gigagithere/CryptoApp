//
//  QuickActionsView.swift
//  CryptoApp
//

import SwiftUI

/// The Buy and Sell buttons at the bottom of the coin detail screen.
struct QuickActionsView: View {
    let onSelect: (TransactionType) -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("Quick Actions")
                .headerText()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            HStack(spacing: Spacing.l) {
                TradingButton(type: .buy) { onSelect(.buy) }
                TradingButton(type: .sell) { onSelect(.sell) }
            }
            .padding(.horizontal)
        }
        .padding(.top, Spacing.xl)
        .padding(.bottom, 30)
    }
}

#Preview {
    QuickActionsView { _ in }
}
