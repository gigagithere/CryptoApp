//
//  TransactionIcon.swift
//  CryptoApp
//
//  Transaction type icon with buy action capability
//

import SwiftUI

struct TransactionIcon: View {
    let transaction: Transaction
    let showBuyModal: Binding<Bool>
    
    var body: some View {
        VStack(spacing: 5) {
            Button(action: {
                if transaction.type == .buy {
                    showBuyModal.wrappedValue = true
                }
            }) {
                ZStack {
                    Circle()
                        .fill(transaction.type == .buy ? .green.opacity(0.1) : .red.opacity(0.1))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: transaction.type == .buy ? "plus" : "minus")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(transaction.type == .buy ? .green : .red)
                }
            }
            .buttonStyle(.plain)
            .disabled(transaction.type != .buy)
            
            Text(transaction.type.rawValue.uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}