//
//  WatchlistButton.swift
//  CryptoApp
//

import SwiftUI

/// The star that adds a coin to, or removes it from, the user's favorites.
struct WatchlistButton: View {
    let coinID: String
    var font: Font = .subheadline

    @Environment(WatchlistViewModel.self) private var watchlist

    var body: some View {
        let isWatched = watchlist.isWatched(coinID)

        Button {
            Task { await watchlist.toggleWatchlist(for: coinID) }
        } label: {
            Image(systemName: isWatched ? "star.fill" : "star")
                .font(font)
                .foregroundStyle(isWatched ? Color.yellow : Color.secondary.opacity(0.6))
                .frame(minWidth: 44, minHeight: 44) // the smallest comfortable tap target
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isWatched)
        .accessibilityLabel(isWatched ? "Remove from favorites" : "Add to favorites")
        .accessibilityInputLabels(["Favorite", "Star"])
    }
}

#Preview {
    WatchlistButton(coinID: "bitcoin")
        .previewEnvironment()
}
