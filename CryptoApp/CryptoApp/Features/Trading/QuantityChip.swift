//
//  QuantityChip.swift
//  CryptoApp
//

import SwiftUI

/// A small quick-pick button under the quantity field: "0,5", "1", "Max".
struct QuantityChip: View {
    private let label: Text
    private let action: () -> Void

    init(quantity: Decimal, action: @escaping () -> Void) {
        self.label = Text(quantity, format: .quantity)
        self.action = action
    }

    init(title: LocalizedStringKey, action: @escaping () -> Void) {
        self.label = Text(title)
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            label
                .font(.footnote)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, 6)
                .background(.fill.tertiary, in: .rect(cornerRadius: Radius.small))
                .frame(minHeight: 44) // tap target bigger than the chip you see
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        QuantityChip(quantity: 0.5) { }
        QuantityChip(title: "Max") { }
    }
}
