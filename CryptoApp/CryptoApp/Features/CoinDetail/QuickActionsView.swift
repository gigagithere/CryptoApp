//
//  QuickActionsView.swift
//  CryptoApp
//

import SwiftUI

/// The Buy and Sell buttons, pinned to the bottom of the coin detail screen.
struct QuickActionsView: View {
    let onSelect: (TransactionType) -> Void

    var body: some View {
        HStack(spacing: Spacing.l) {
            TradingButton(type: .buy) { onSelect(.buy) }
            TradingButton(type: .sell) { onSelect(.sell) }
        }
        .padding(.horizontal)
        .padding(.vertical, Spacing.s)
        .background(.bar)
    }
}

#Preview {
    QuickActionsView { _ in }
}
