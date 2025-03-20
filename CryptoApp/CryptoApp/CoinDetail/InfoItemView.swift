//
//  InfoItemView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 18/03/2025.
//

import Foundation
import SwiftUI

struct InfoItemView: View {
    let title: String
    let value: String
    let footnote: String?
    
    private var percentFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        return formatter
    }
    
    private var footnoteColor: Color {
        guard let footnote = footnote else { return .primary }
        let cleaned = footnote.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "%", with: "")
        guard let number = percentFormatter.number(from: cleaned) else { return .primary }
        return number.doubleValue >= 0 ? .green : .red
    }
    
    private var footnoteIcon: String {
        guard let footnote = footnote else { return "" }
        let cleaned = footnote.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "%", with: "")
        guard let number = percentFormatter.number(from: cleaned) else { return "" }
        return number.doubleValue >= 0 ? "arrow.up" : "arrow.down"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .foregroundStyle(.secondary)
                .font(.headline)
            Text(value)
                .font(.headline)
                .bold()
            
            if let footnote = footnote {
                HStack {
                    if !footnoteIcon.isEmpty {
                        Image(systemName: footnoteIcon)
                            .font(.footnote)
                            .foregroundColor(footnoteColor)
                    }
                    Text(footnote)
                        .font(.footnote)
                        .foregroundColor(footnoteColor)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity,alignment: .leading)
        .frame(height: 100)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
