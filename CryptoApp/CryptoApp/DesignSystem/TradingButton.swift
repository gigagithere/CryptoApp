//
//  TradingButton.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI

// MARK: - Trading button component for buy/sell actions

struct TradingButton: View {
    let type: TransactionType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(type.title, systemImage: type.systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: Radius.medium))
        .controlSize(.large)
        .tint(type.color)
    }
}

#Preview {
    HStack(spacing: 16) {
        TradingButton(type: .buy) { }
        TradingButton(type: .sell) { }
    }
    .padding()
}
