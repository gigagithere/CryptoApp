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
    
    /// - Parameters:
    ///   - initialQuantity: what the quantity field starts with
    ///   - maxQuantity: the most that can be traded (what you own, when selling); nil for no limit
    init(coinID: String, type: TransactionType, initialQuantity: Decimal = 1, maxQuantity: Decimal? = nil) {
        self.coinID = coinID
        _trade = State(initialValue: TradeViewModel(coinID: coinID, type: type,
                                                    quantity: initialQuantity, maxQuantity: maxQuantity))
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
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: Spacing.m) {
                        CoinImage(url: coin.image, symbol: coin.symbol, size: 40)
                            .clipShape(.circle)
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Label("\(trade.type.title) \(coin.name)", systemImage: trade.type.systemImage)
                                .font(.title2)
                                .bold()
                                .foregroundStyle(trade.type.color)
                            
                            Text(symbol)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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
                    
                    VStack(alignment: .leading, spacing: Spacing.m) {
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
                        }
                        
                        HStack(spacing: Spacing.m) {
                            ForEach(TradeViewModel.presets, id: \.self) { preset in
                                QuantityChip(quantity: preset) { trade.quantity = preset }
                            }
                            if let maxQuantity = trade.maxQuantity {
                                QuantityChip(title: "Max") { trade.quantity = maxQuantity }
                            }
                        }
                        .sensoryFeedback(.selection, trigger: trade.quantity)
                        
                        if trade.exceedsMax {
                            Label("You only own \(holding.formatted(.quantity)) \(symbol)", systemImage: "exclamationmark.triangle.fill")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    TradeInfoCard(title: "Total Value") {
                        Text(trade.total(at: price), format: .usdAmount)
                            .font(.title)
                            .bold()
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            // The confirm button stays above the keyboard and the bottom edge
            .safeAreaInset(edge: .bottom) {
                Button(action: execute) {
                    Group {
                        if trade.isProcessing {
                            ProgressView()
                        } else {
                            Text("\(trade.type.title) \(symbol)")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: Radius.large))
                .controlSize(.large)
                .tint(trade.type.color)
                .disabled(!trade.canSubmit)
                .accessibilityInputLabels([trade.type.title, String(localized: "Confirm")])
                .padding(.horizontal)
                .padding(.vertical, Spacing.s)
                .background(.bar)
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
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .alert("Trade Executed", isPresented: $showConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            // Past tense ("bought"/"sold"), not `trade.type.title.lowercased()` ("buy"/"sell"): the trade already happened.
            Text("Successfully \(trade.type.pastTenseVerb) \(trade.quantityValue, format: .quantity) \(symbol) for \(trade.total(at: price), format: .usdAmount)")
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
