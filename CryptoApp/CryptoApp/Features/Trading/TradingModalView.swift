//
//  TradingModalView.swift
//  CryptoApp
//
//  Sheet for buying or selling a coin: quantity input, total, and the confirm button.
//  The trade itself runs in TradeViewModel / PortfolioViewModel.
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI

struct TradingModalView: View {
    let coinID: String
    
    @State private var trade: TradeViewModel
    @State private var showConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var isQuantityFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(CoinService.self) private var coinService
    @Environment(PortfolioViewModel.self) private var portfolio
    
    init(coinID: String, type: TransactionType) {
        self.coinID = coinID
        _trade = State(initialValue: TradeViewModel(coinID: coinID, type: type))
    }
    
    var body: some View {
        if let coin = coinService.coin(id: coinID) {
            content(for: coin)
        } else {
            ContentUnavailableView("Coin not found", systemImage: "questionmark.circle")
        }
    }
    
    private func content(for coin: Coin) -> some View {
        // Live market price - the same one the trade is executed at
        let price = Decimal(price: coin.currentPrice)
        let holding = portfolio.getTotalHolding(for: coin.id)
        let symbol = coin.symbol.uppercased()
        
        return NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            CoinImage(url: coin.image, symbol: coin.symbol, size: 40)
                                .clipShape(.circle)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Label("\(trade.type.title) \(coin.name)", systemImage: trade.type.systemImage)
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(trade.type.color)
                                
                                Text(symbol)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text("Current Price: \(price, format: .usd)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    TradeInfoCard(title: "Price per \(symbol)") {
                        Text(price, format: .usd)
                            .font(.title)
                            .bold()
                            .foregroundStyle(trade.type.color)
                    }
                    
                    if trade.type == .sell {
                        TradeInfoCard(title: "Your Holdings") {
                            Text("\(holding, format: .quantity) \(symbol)")
                                .headerText()
                                .foregroundStyle(holding > 0 ? .green : .red)
                            
                            if holding == 0 {
                                Text("You don't own any \(symbol)")
                                    .secondaryText()
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quantity")
                            .headlineText()
                        
                        HStack {
                            TextField("Enter quantity", value: $trade.quantity, format: .quantity.grouping(.never))
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .font(.title2)
                                .focused($isQuantityFocused)
                            
                            Text(symbol)
                                .headlineText()
                                .foregroundStyle(.secondary)
                                .padding(.trailing, 8)
                        }
                        
                        HStack(spacing: 12) {
                            ForEach(TradeViewModel.presets, id: \.self) { preset in
                                Button {
                                    trade.quantity = preset
                                } label: {
                                    Text(preset, format: .quantity)
                                        .font(.footnote)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.gray.opacity(0.2))
                                        .clipShape(.rect(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                        }
                        .sensoryFeedback(.selection, trigger: trade.quantity)
                    }
                    
                    TradeInfoCard(title: "Total Value") {
                        Text(trade.total(at: price), format: .usd)
                            .font(.title)
                            .bold()
                    }
                    
                    Button {
                        execute()
                    } label: {
                        Group {
                            if trade.isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("\(trade.type.title) \(symbol)")
                                    .headlineText()
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(trade.canSubmit ? trade.type.color : .gray)
                        .clipShape(.rect(cornerRadius: 16))
                    }
                    .disabled(!trade.canSubmit)
                    .padding(.bottom, 40) // Extra bottom padding for keyboard safety
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isQuantityFocused = false }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Trade Executed", isPresented: $showConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text("Successfully \(trade.type.title.lowercased()) \(trade.quantityValue, format: .quantity) \(symbol) for \(trade.total(at: price), format: .usd)")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sensoryFeedback(.success, trigger: showConfirmation) { _, new in new }
        .sensoryFeedback(.error, trigger: showError) { _, new in new }
    }
    
    private func execute() {
        Task {
            do {
                try await trade.execute(using: portfolio)
                showConfirmation = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    TradingModalView(coinID: Coin.sample.id, type: .buy)
        .previewEnvironment()
}
