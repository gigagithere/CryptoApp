//
//  MarketStatusView.swift
//  CryptoApp
//

import SwiftUI

struct MarketStatusView: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Market Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 6) {
                StatusDotGlowView()
                Text("Live")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
        }
    }
}

#Preview {
    MarketStatusView()
}
