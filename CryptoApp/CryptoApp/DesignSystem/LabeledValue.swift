//
//  LabeledValue.swift
//  CryptoApp
//

import SwiftUI

/// A small caption above a value: "Quantity" over "0.25".
struct LabeledValue<Value: View>: View {
    let title: LocalizedStringKey
    var alignment: HorizontalAlignment = .leading
    @ViewBuilder let value: Value

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title)
                .secondaryText()
            value
        }
    }
}

#Preview {
    LabeledValue(title: "Quantity") {
        Text(0.25, format: .number)
            .font(.subheadline.weight(.medium))
    }
}
