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
    @Environment(PortfolioViewModel.self) private var portfolio
    @State private var showSellConfirmation = false
    @State private var showSellError = false
    @State private var sellErrorMessage = ""
    
    var body: some View {
        let currentValue = holding.currentValue(currentPrice: currentPrice)
        let profitLoss = holding.profitLoss(currentPrice: currentPrice)
        let profitLossPercentage = holding.profitLossPercentage(currentPrice: currentPrice)
        
        VStack(spacing: Spacing.m) {
            HStack {
                // Opens the live coin; disabled while there is no market price for it
                NavigationLink(value: Route.coin(id: holding.coinId)) {
                    HStack(spacing: Spacing.m) {
                        CoinImage(url: holding.imageUrl, symbol: holding.coinSymbol)
                        Text(holding.coinSymbol.uppercased())
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(.plain)
                .disabled(coinService.coin(id: holding.coinId) == nil)
                
                Spacer()
                
                Button {
                    showSellConfirmation = true
                } label: {
                    Label("Sell", systemImage: "minus.circle")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical, Spacing.xs)
                        .background(.red.opacity(0.1), in: .rect(cornerRadius: Radius.small))
                        .foregroundStyle(.red)
                        .frame(minHeight: 44) // tap target bigger than the chip you see
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Sell \(holding.coinSymbol.uppercased())")
                .accessibilityInputLabels(["Sell", "Sell \(holding.coinSymbol.uppercased())"])
            }
            
            HStack {
                LabeledValue(title: "Quantity") {
                    Text(holding.quantity, format: .quantity)
                        .font(.subheadline.weight(.medium))
                }
                
                Spacer()
                
                LabeledValue(title: "Current Value", alignment: .trailing) {
                    Text(currentValue, format: .usdAmount)
                        .font(.subheadline.weight(.medium))
                }
            }
            
            HStack {
                LabeledValue(title: "Avg. Buy Price") {
                    Text(holding.averagePurchasePrice, format: .usd)
                        .font(.subheadline.weight(.medium))
                }
                
                Spacer()
                
                LabeledValue(title: "P&L", alignment: .trailing) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: profitLoss >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text("\(profitLoss, format: .usdChange) (\(profitLossPercentage / 100, format: .percentChangeSigned))")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(profitLoss >= 0 ? .green : .red)
                }
            }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.m)
        .card(elevated: true)
        .alert("Sell \(holding.coinSymbol.uppercased())?", isPresented: $showSellConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sell All", role: .destructive) {
                Task { await sellAll() }
            }
        } message: {
            Text("This will sell all \(holding.quantity, format: .quantity) \(holding.coinSymbol.uppercased()) from your portfolio for \(currentValue, format: .usdAmount).")
        }
        .alert("Couldn't sell", isPresented: $showSellError) {
            Button("OK") { }
        } message: {
            Text(sellErrorMessage)
        }
        .sensoryFeedback(.error, trigger: showSellError) { _, new in new }
    }
    
    private func sellAll() async {
        do {
            try await portfolio.sell(coinId: holding.coinId, quantity: holding.quantity)
        } catch {
            sellErrorMessage = error.localizedDescription
            showSellError = true
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
