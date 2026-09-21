//
//  CurrentHoldingsRowView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 06/08/2025.
//


import SwiftUI
import Kingfisher

struct CurrentHoldingsRowView: View {
    let holding: Holding
    let currentPrice: Decimal
    private var portfolioViewModel: any PortfolioViewModelProtocol
    private let coinService: CoinServiceProtocol
    private var watchlistViewModel: any WatchlistViewModelProtocol
    @State private var showSellConfirmation = false
    
    init(holding: Holding, currentPrice: Decimal, portfolioViewModel: any PortfolioViewModelProtocol, coinService: CoinServiceProtocol, watchlistViewModel: any WatchlistViewModelProtocol) {
        self.holding = holding
        self.currentPrice = currentPrice
        self.portfolioViewModel = portfolioViewModel
        self.coinService = coinService
        self.watchlistViewModel = watchlistViewModel
    }
    
    private var currentValue: Decimal {
        holding.quantity * currentPrice
    }
    
    private var profitLoss: Decimal {
        currentValue - holding.totalInvested
    }
    
    private var profitLossPercentage: Decimal {
        guard holding.totalInvested > 0 else { return 0 }
        return (profitLoss / holding.totalInvested) * 100
    }
    
    private var coin: Coin {
        Coin(
            id: holding.coinId,
            symbol: holding.coinSymbol,
            name: holding.coinSymbol.uppercased(),
            image: holding.imageUrl,
            currentPrice: currentPrice.doubleValue,
            marketCap: nil,
            marketCapRank: 0,
            fullyDilutedValuation: nil,
            totalVolume: nil,
            high24H: nil,
            low24H: nil,
            priceChange24H: 0,
            priceChangePercentage24H: 0,
            marketCapChange24H: nil,
            marketCapChangePercentage24H: nil,
            circulatingSupply: nil,
            totalSupply: nil,
            maxSupply: nil,
            ath: nil,
            athChangePercentage: 0,
            athDate: nil,
            atl: nil,
            atlChangePercentage: nil,
            atlDate: nil,
            lastUpdated: nil,
            sparklineIn7D: nil
        )
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                NavigationLink(destination: CoinDetailView(coin: coin, coinService: coinService, portfolioViewModel: portfolioViewModel, watchlistViewModel: watchlistViewModel)) {
                    HStack(spacing: 12) {
                        KFImage(URL(string: holding.imageUrl))
                            .placeholder {
                                Circle()
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 28, height: 28)
                                    .overlay {
                                        Text(holding.coinSymbol.prefix(1).uppercased())
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    }
                            }
                            .retry(maxCount: 3, interval: .seconds(1))
                            .fade(duration: 0.25)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        
                        Text(holding.coinSymbol.uppercased())
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
                
                Button(action: {
                    showSellConfirmation = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "minus.circle")
                            .font(.caption)
                        Text("Sell")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red.opacity(0.1))
                    .foregroundColor(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quantity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(holding.quantity.asQuantityString())
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(currentValue.asCurrencyString())
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg. Buy Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(holding.averagePurchasePrice.asCurrencyString())
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("P&L")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: profitLoss >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text("\(profitLoss.asCurrencyString()) (\(profitLossPercentage.asPercentageString()))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(profitLoss >= 0 ? .green : .red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .alert("Sell \(holding.coinSymbol.uppercased())?", isPresented: $showSellConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sell All", role: .destructive) {
                HapticFeedback.impact(.heavy)
                Task {
                    await portfolioViewModel.removeFromPortfolio(holding)
                }
            }
        } message: {
            Text("This will sell all \(holding.quantity.asQuantityString()) \(holding.coinSymbol.uppercased()) from your portfolio for \(currentValue.asCurrencyString()).")
        }
    }
}

#Preview {
    CurrentHoldingsRowView(
        holding: Holding(
            coinId: "bitcoin",
            coinSymbol: "BTC",
            quantity: 0.25,
            purchasePrice: 42000,
            date: Date().addingTimeInterval(-86400 * 10),
            imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
        ),
        currentPrice: 45000,
        portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()),
        coinService: MockCoinService(),
        watchlistViewModel: WatchlistViewModel(authService: AuthService.shared)
    )
    .padding()
    .background(Color(.systemBackground))
}
