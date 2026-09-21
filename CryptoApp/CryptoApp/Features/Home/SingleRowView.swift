//
//  SingleRowView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 01/03/2025.
//

import SwiftUI
import Kingfisher

// MARK: - SingleRowView

struct SingleRowView: View {
    let coin: Coin
    @Environment(WatchlistViewModel.self) private var watchlist
    
    private var isWatched: Bool {
        watchlist.isWatched(coin.id)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            starButtonView
            rankView
            coinImageView
            coinInfoView
            
            Spacer()
            
            priceInfoView
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
    
    // MARK: - Computed Properties for Clean UI
    private var starButtonView: some View {
        Button(action: {
            Task {
                await watchlist.toggleWatchlist(for: coin.id)
            }
        }) {
            Image(systemName: isWatched ? "star.fill" : "star")
                .secondaryText()
                .foregroundColor(isWatched ? .yellow : .gray.opacity(0.4))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isWatched)
        .padding(.trailing, 13)
    }
    
    private var rankView: some View {
        Text("\(coin.marketCapRank)")
            .secondaryText()
            .fontWeight(.medium)
            .frame(width: 20, alignment: .leading)
    }
    
    private var coinImageView: some View {
        KFImage(URL(string: coin.image))
            .placeholder {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .overlay {
                        Text(coin.symbol.prefix(1).uppercased())
                            .secondaryText()
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
            }
            .retry(maxCount: 3, interval: .seconds(2))
            .fade(duration: 0.25)
            .resizable()
            .scaledToFit()
            .frame(width: 28, height: 28)
    }
    
    private var coinInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(coin.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(coin.symbol.uppercased())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
    
    private var priceInfoView: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(Decimal(coin.currentPrice).asCurrencyString())
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack(spacing: 3) {
                Image(systemName: coin.priceChangePercentage24H >= 0 ? "plus" : "minus")
                    .font(.caption2)
                
                Text(Decimal(abs(coin.priceChangePercentage24H)).asPercentageString())
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(coin.priceChangePercentage24H >= 0 ? .green : .red)
        }
    }
}


#Preview {
    SingleRowView(coin: Coin.sample)
        .previewEnvironment()
}
