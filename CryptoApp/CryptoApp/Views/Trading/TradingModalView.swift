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
    let coin: Coin
    let tradeType: TradingButton.ButtonType
    private var portfolioViewModel: any PortfolioViewModelProtocol
    
    // 💱 Trading state variables
    @State private var quantity: String = "1"
    @State private var totalValue: Decimal = 0
    @State private var showConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    
    // 🌍 Environment and services
    @Environment(\.dismiss) private var dismiss
    
    init(coin: Coin, tradeType: TradingButton.ButtonType, portfolioViewModel: any PortfolioViewModelProtocol) {
        self.coin = coin
        self.tradeType = tradeType
        self.portfolioViewModel = portfolioViewModel
    }
    
    private var quantityValue: Decimal {
        // Handle both comma and dot as decimal separators
        let normalizedQuantity = quantity.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalizedQuantity) ?? 0
    }
    
    private var calculatedTotal: Decimal {
        quantityValue * Decimal(coin.currentPrice)
    }
    
    private var currentHolding: Decimal {
        portfolioViewModel.getTotalHolding(for: coin.id)
    }
    
    var body: some View {
        NavigationView {
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
                                    Image(systemName: tradeType.systemImage)
                                        .font(.title2)
                                        .foregroundColor(tradeType.color)
                                    
                                    Text("\(tradeType.title) \(coin.name)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                
                                Text(coin.symbol.uppercased())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text("Current Price: \(Decimal(coin.currentPrice).asCurrencyString())")
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
                            
                            Text(Decimal(coin.currentPrice).asCurrencyString())
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(tradeType.color)
                        }
                        .cardStyle()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Show current holdings for sell orders
                        if tradeType == .sell {
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
                                .onChange(of: quantity) { _, _ in
                                    updateTotal()
                                }
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
                                    updateTotal()
                                    HapticFeedback.impact(.light)
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
                            executeTrade()
                        }) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Text("\(tradeType.title) \(coin.symbol.uppercased())")
                                        .headlineText()
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(quantityValue <= 0 || isProcessing ? .gray : tradeType.color)
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
            Text("Successfully \(tradeType.title.lowercased()) \(quantityValue.asQuantityString()) \(coin.symbol.uppercased()) for \(calculatedTotal.asCurrencyString())")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            updateTotal()
        }
    }
    
    private func updateTotal() {
        totalValue = calculatedTotal
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func executeTrade() {
        // Start processing state
        isProcessing = true
        
        // Execute async trade
        Task {
            await performTrade()
        }
    }
    
    private func performTrade() async {
        HapticFeedback.impact(.heavy)
        
        if tradeType == .buy {
            // BUY - Add to portfolio using async method
            await portfolioViewModel.addToPortfolio(
                coinId: coin.id,
                coinSymbol: coin.symbol,
                quantity: quantityValue,
                purchasePrice: Decimal(coin.currentPrice),
                imageUrl: coin.image
            )
            
            // Check for errors from ViewModel
            if portfolioViewModel.errorMessage != nil {
                errorMessage = portfolioViewModel.errorMessage ?? "Unable to complete buy order."
                isProcessing = false
                showError = true
                
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
                return
            }
            
            // Success state
            isProcessing = false
            showConfirmation = true
            
            // Add haptic feedback for success
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
            
        } else {
            // SELL - Validate holdings first
            if quantityValue > currentHolding {
                if currentHolding == 0 {
                    errorMessage = "You don't own any \(coin.symbol.uppercased()) to sell."
                } else {
                    errorMessage = "Insufficient funds! You only have \(currentHolding.asQuantityString()) \(coin.symbol.uppercased()) available to sell."
                }
                
                isProcessing = false
                showError = true
                
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
                return
            }
            
            // SELL - Execute sell order using async method
            let success = await portfolioViewModel.sellFromPortfolio(coinId: coin.id, quantityToSell: quantityValue)
            
            if success && portfolioViewModel.errorMessage == nil {
                // Success state
                isProcessing = false
                showConfirmation = true
                
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
            } else {
                errorMessage = portfolioViewModel.errorMessage ?? "Unable to complete sell order. Please try again."
                
                isProcessing = false
                showError = true
                
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
            }
        }
    }
}

#Preview {
    TradingModalView(coin: Coin.sample, tradeType: .buy, portfolioViewModel: PortfolioViewModel(authService: AuthService.shared, coinService: MockCoinService()))
}
