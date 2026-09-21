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
        
        VStack(spacing: 12) {
            HStack {
                // Opens the live coin; disabled while there is no market price for it
                NavigationLink(value: Route.coin(id: holding.coinId)) {
                    HStack(spacing: 12) {
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(.rect(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            
            HStack {
                LabeledValue(title: "Quantity") {
                    Text(holding.quantity, format: .quantity)
                        .font(.subheadline.weight(.medium))
                }
                
                Spacer()
                
                LabeledValue(title: "Current Value", alignment: .trailing) {
                    Text(currentValue, format: .usd)
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
                    HStack(spacing: 4) {
                        Image(systemName: profitLoss >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                        Text("\(profitLoss, format: .usd) (\(profitLossPercentage / 100, format: .percentChange))")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(profitLoss >= 0 ? .green : .red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .alert("Sell \(holding.coinSymbol.uppercased())?", isPresented: $showSellConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sell All", role: .destructive) {
                Task { await sellAll() }
            }
        } message: {
            Text("This will sell all \(holding.quantity, format: .quantity) \(holding.coinSymbol.uppercased()) from your portfolio for \(currentValue, format: .usd).")
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
