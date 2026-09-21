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
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isWatched)
    }
}

#Preview {
    WatchlistButton(coinID: "bitcoin")
        .previewEnvironment()
}
