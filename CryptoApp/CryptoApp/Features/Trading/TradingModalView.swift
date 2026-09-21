//
//  TradingModalView.swift
//  CryptoApp
//
//  ⭐⭐ BUY/SELL FUNCTIONALITY ⭐⭐
//  Modal view for executing cryptocurrency trades
//  Handles quantity input, total calculation, and trade execution
//  Integrates with PortfolioViewModel for actual trading operations
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI
import Kingfisher

// MARK: - Trading Modal View
/// 💰 Modal for buying/selling cryptocurrency
/// Handles trade input, validation, and execution with rocket animations
struct TradingModalView: View {
    // 🪙 Coin to trade and trade type (buy/sell)
    let coinID: String
    let type: TransactionType
    
    // 💱 Trading state variables
    @State private var quantity: String = "1"
    @State private var showConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    
    // 🌍 Environment and services
    @Environment(\.dismiss) private var dismiss
    @Environment(CoinService.self) private var coinService
    @Environment(PortfolioViewModel.self) private var portfolio
    
    private var quantityValue: Decimal {
        // Handle both comma and dot as decimal separators
        let normalizedQuantity = quantity.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalizedQuantity) ?? 0
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
        let currentPrice = Decimal(price: coin.currentPrice)
        let calculatedTotal = quantityValue * currentPrice
        let currentHolding = portfolio.getTotalHolding(for: coin.id)
        
        return NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            KFImage(URL(string: coin.image))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: type.systemImage)
                                        .font(.title2)
                                        .foregroundColor(type.color)
                                    
                                    Text("\(type.title) \(coin.name)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                
                                Text(coin.symbol.uppercased())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text("Current Price: \(currentPrice.asCurrencyString())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Current Price Display
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Price per \(coin.symbol.uppercased())")
                                .headlineText()
                                .foregroundColor(.secondary)
                            
                            Text(currentPrice.asCurrencyString())
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(type.color)
                        }
                        .cardStyle()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Show current holdings for sell orders
                        if type == .sell {
                            VStack(spacing: 8) {
                                Text("Your Holdings")
                                    .headlineText()
                                    .foregroundColor(.secondary)
                                
                                Text("\(currentHolding.asQuantityString()) \(coin.symbol.uppercased())")
                                    .headerText()
                                    .foregroundColor(currentHolding > 0 ? .green : .red)
                                
                                if currentHolding == 0 {
                                    Text("You don't own any \(coin.symbol.uppercased())")
                                        .secondaryText()
                                        .foregroundColor(.red)
                                }
                            }
                            .cardStyle()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    
                    // Quantity Input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quantity")
                            .headlineText()
                        
                        HStack {
                            TextField("Enter quantity", text: $quantity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .font(.title2)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            hideKeyboard()
                                        }
                                    }
                                }
                            
                            Text(coin.symbol.uppercased())
                                .headlineText()
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                        
                        // Quantity Presets
                        HStack(spacing: 12) {
                            ForEach([0.1, 0.5, 1.0, 5.0], id: \.self) { amount in
                                Button(action: {
                                    quantity = String(format: amount == floor(amount) ? "%.0f" : "%.1f", amount)
                                }) {
                                    Text(String(format: amount == floor(amount) ? "%.0f" : "%.1f", amount))
                                        .font(.footnote)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.gray.opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                        }
                    }
                    
                    // Total Value
                    VStack(spacing: 8) {
                        Text("Total Value")
                            .headlineText()
                            .foregroundColor(.secondary)
                        
                        Text(calculatedTotal.asCurrencyString())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .cardStyle()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Action Buttons - moved inside ScrollView, more spacing at bottom
                    VStack(spacing: 16) {
                        Button(action: {
                            executeTrade(coin)
                        }) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Text("\(type.title) \(coin.symbol.uppercased())")
                                        .headlineText()
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(quantityValue <= 0 || isProcessing ? .gray : type.color)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(quantityValue <= 0 || isProcessing)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .headlineText()
                        .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40) // Extra bottom padding for keyboard safety
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .alert("Trade Executed", isPresented: $showConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Successfully \(type.title.lowercased()) \(quantityValue.asQuantityString()) \(coin.symbol.uppercased()) for \(calculatedTotal.asCurrencyString())")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sensoryFeedback(.success, trigger: showConfirmation) { _, new in new }
        .sensoryFeedback(.error, trigger: showError) { _, new in new }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func executeTrade(_ coin: Coin) {
        isProcessing = true
        
        Task {
            do {
                switch type {
                case .buy:
                    try await portfolio.buy(coinId: coin.id, quantity: quantityValue)
                case .sell:
                    try await portfolio.sell(coinId: coin.id, quantity: quantityValue)
                }
                isProcessing = false
                showConfirmation = true
            } catch {
                errorMessage = error.localizedDescription
                isProcessing = false
                showError = true
            }
        }
    }
}

#Preview {
    TradingModalView(coinID: Coin.sample.id, type: .buy)
        .previewEnvironment()
}
