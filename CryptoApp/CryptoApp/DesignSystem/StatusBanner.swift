//
//  StatusBanner.swift
//  CryptoApp
//

import SwiftUI

/// A one-line notice above the content: "Showing saved prices", "Couldn't refresh".
struct StatusBanner: View {
    let systemImage: String
    let tint: Color
    let message: Text

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: systemImage)
            message
                .font(.footnote)
            Spacer(minLength: 0)
        }
        .foregroundStyle(tint)
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.12), in: .rect(cornerRadius: Radius.small))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatusBanner(systemImage: "icloud.slash", tint: .orange, message: Text("Showing saved prices"))
        .padding()
}
