//
//  DividerView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 30/01/2025.
//

import SwiftUI

// MARK: - DividerView

struct DividerView: View {
    var body: some View {
        HStack {
            Divider()
                .frame(width: 150, height: 1)
                .overlay(.gray.opacity(0.3))
            
            Text("OR")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.horizontal, Spacing.s)
            
            Divider()
                .frame(width: 150, height: 1)
                .overlay(.gray.opacity(0.3))
        }
    }
}

#Preview {
    DividerView()
}
