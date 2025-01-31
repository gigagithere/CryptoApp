//
//  DividerView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 30/01/2025.
//

import SwiftUI

struct DividerView: View {
    var body: some View {
        HStack {
            Divider()
                .frame(width: 150, height: 1)
                .overlay(.gray.opacity(0.3))
            
            Text("OR")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
            
            Divider()
                .frame(width: 150, height: 1)
                .overlay(.gray.opacity(0.3))
        }
    }
}

#Preview {
    DividerView()
}
