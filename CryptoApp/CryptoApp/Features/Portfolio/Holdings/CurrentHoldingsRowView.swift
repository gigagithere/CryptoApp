//
//  CurrentHoldingsRowView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 06/08/2025.
//

import SwiftUI

struct CurrentHoldingsRowView: View {
    let holding: Holding
    let currentPrice: Decimal
    @Environment(CoinService.self) private var coinService
    @State private var tradeType: TransactionType?
    
    var body: some View {
        let currentValue = holding.currentValue(currentPrice: currentPrice)
        let profitLoss = holding.profitLoss(currentPrice: currentPrice)
        let profitLossPercentage = holding.profitLossPercentage(currentPrice: currentPrice)
        // Trading needs a live price, so both the link and the Sell button wait for one
        let hasLivePrice = coinService.coin(id: holding.coinId) != nil
        
        VStack(spacing: Spacing.m) {
            HStack {
                NavigationLink(value: Route.coin(id: holding.coinId)) {
                    HStack(spacing: Spacing.m) {
                        CoinImage(url: holding.imageUrl, symbol: holding.coinSymbol)
                        Text(holding.coinSymbol.uppercased())
                            .font(.headline)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!hasLivePrice)
                
                Spacer()
                
                Button {
                    tradeType = .sell
                } label: {
                    Label("Sell", systemImage: "minus.circle")
                        .font(.caption)
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical, Spacing.xs)
                        .background(.red.opacity(0.1), in: .rect(cornerRadius: Radius.small))
                        .foregroundStyle(.red)
                        .frame(minHeight: 44) // tap target bigger than the chip you see
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .disabled(!hasLivePrice)
                .accessibilityLabel("Sell \(holding.coinSymbol.uppercased())")
                .accessibilityInputLabels(["Sell", "Sell \(holding.coinSymbol.uppercased())"])
            }
            
            HStack {
                LabeledValue(title: "Quantity") {
                    Text(holding.quantity, format: .quantity)
                        .font(.subheadline)
                }
                
                Spacer()
                
                LabeledValue(title: "Current Value", alignment: .trailing) {
                    Text(currentValue, format: .usdAmount)
                        .font(.subheadline)
                }
            }
            
            HStack {
                LabeledValue(title: "Avg. Buy Price") {
                    Text(holding.averagePurchasePrice, format: .usd)
                        .font(.subheadline)
                }
                
                Spacer()
                
                LabeledValue(title: "P&L", alignment: .trailing) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: profitLoss >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text("\(profitLoss, format: .usdChange) (\(profitLossPercentage / 100, format: .percentChangeSigned))")
                            .font(.subheadline)
                    }
                    .foregroundStyle(profitLoss >= 0 ? .green : .red)
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.m)
        .card(elevated: true)
        // Selling opens the same sheet as the coin screen, with everything you own filled in; change it to sell less
        .sheet(item: $tradeType) { type in
            TradingModalView(coinID: holding.coinId, type: type,
                             initialQuantity: holding.quantity, maxQuantity: holding.quantity)
        }
    }
}

#Preview {
    NavigationStack {
        CurrentHoldingsRowView(
            holding: Holding(
                coinId: "bitcoin",
                coinSymbol: "BTC",
                quantity: 0.25,
                purchasePrice: 42000,
                date: .now.addingTimeInterval(-86400 * 10),
                imageUrl: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
            ),
            currentPrice: 45000
        )
        .padding()
    }
    .previewEnvironment()
}
