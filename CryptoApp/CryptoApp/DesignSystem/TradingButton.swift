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
            HStack(spacing: 8) {
                Image(systemName: type.systemImage)
                    .font(.headline)
                Text(type.title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(type.color)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        TradingButton(type: .buy) {
            // Buy action
        }
        
        TradingButton(type: .sell) {
            // Sell action
        }
    }
    .padding()
}
