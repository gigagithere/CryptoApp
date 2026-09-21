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
            HStack(spacing: Spacing.s) {
                Image(systemName: type.systemImage)
                    .font(.headline)
                Text(type.title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(type.color)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: Radius.medium))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: Spacing.l) {
        TradingButton(type: .buy) {
            // Buy action
        }
        
        TradingButton(type: .sell) {
            // Sell action
        }
    }
    .padding()
}
