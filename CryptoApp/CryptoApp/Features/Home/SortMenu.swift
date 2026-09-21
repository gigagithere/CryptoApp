//
//  SortMenu.swift
//  CryptoApp
//

import SwiftUI

/// The "Sort" dropdown above the coin list.
struct SortMenu: View {
    @Binding var option: SortOption
    @Binding var order: SortOrder

    var body: some View {
        Menu {
            Section("Sort By") {
                ForEach(SortOption.allCases, id: \.self) { sortOption in
                    Button {
                        option = sortOption
                        order = .descending // the usual best default for every option
                    } label: {
                        Label(sortOption.rawValue, systemImage: sortOption.iconName)
                    }
                }
            }

            if option.hasDirectionControl {
                Section("Order") {
                    ForEach(SortOrder.allCases, id: \.self) { sortOrder in
                        Button {
                            order = sortOrder
                        } label: {
                            Label(sortOrder.rawValue, systemImage: sortOrder == .ascending ? "arrow.up" : "arrow.down")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.iconName)
                Text("Sort")
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(minHeight: 44)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: option)
        .sensoryFeedback(.selection, trigger: order)
    }
}

#Preview {
    SortMenu(option: .constant(.marketCap), order: .constant(.descending))
}
