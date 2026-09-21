//
//  PortfolioViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 15/08/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
protocol PortfolioViewModelProtocol: Observable {
    var holdings: [Holding] { get }
    var transactions: [Transaction] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    
    func loadPortfolioData() async
    func clearLocalData()
    func clearError()
    func addToPortfolio(coinId: String, coinSymbol: String, quantity: Decimal, purchasePrice: Decimal, imageUrl: String) async
    func removeFromPortfolio(_ holding: Holding) async
    func sellFromPortfolio(coinId: String, quantityToSell: Decimal) async -> Bool
    func getCurrentPrice(for coinId: String) -> Decimal?
    func getTotalHolding(for coinId: String) -> Decimal
    
    func totalPortfolioValue() -> Decimal
    func totalInvestment() -> Decimal
    func totalProfitLoss() -> Decimal
    func totalProfitLossPercentage() -> Decimal
    
    var holdingsCount: Int { get }
    var transactionCount: Int { get }
}

@MainActor
@Observable
class PortfolioViewModel: PortfolioViewModelProtocol {
    // STATE - What the UI displays
    var holdings: [Holding] = []
    var transactions: [Transaction] = []
    var isLoading = false
    var lastError: PortfolioError?
    
    // Helper for UI error display
    var errorMessage: String? {
        lastError?.localizedDescription
    }
    
    // DEPENDENCIES - Services this ViewModel needs
    private let firestoreService: PortfolioFirestoreServiceProtocol
    private let authService: AuthService
    private let coinService: CoinServiceProtocol
    
    // INITIALIZATION - Set up ViewModel with required services
    init(firestoreService: PortfolioFirestoreServiceProtocol = PortfolioFirestoreService(),
         authService: AuthService,
         coinService: CoinServiceProtocol) {
        self.firestoreService = firestoreService
        self.authService = authService
        self.coinService = coinService
        
        // Listen for auth changes to reload data
        observeAuthChanges()
    }
    
    // AUTH OBSERVATION - React to authentication state changes
    private func observeAuthChanges() {
        // Note: This will be handled by the UI layer with .onChange(of: authService.isAuthenticated)
        // No NotificationCenter needed with @Observable pattern
    }
    
    // LOAD DATA - Get user's portfolio from Firestore
    func loadPortfolioData() async {
        guard let userId = authService.userSession?.uid else {
            lastError = .userNotAuthenticated
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Load both holdings and transactions concurrently
            async let holdingsResult = firestoreService.loadHoldings(userId: userId)
            async let transactionsResult = firestoreService.loadTransactions(userId: userId)
            
            self.holdings = try await holdingsResult
            self.transactions = try await transactionsResult
            
            self.lastError = nil
        } catch {
            self.lastError = .firestoreLoadFailed
        }
    }
    
    // CLEAR LOCAL DATA - Remove cached data when user logs out
    func clearLocalData() {
        holdings = []
        transactions = []
        lastError = nil
    }
    
    func clearError() {
        lastError = nil
    }
    
    /// Efficient price lookup for portfolio calculations
    private var currentPrices: [String: Decimal] {
        Dictionary(uniqueKeysWithValues: coinService.coins.map { ($0.id, Decimal($0.currentPrice)) })
    }
    
    /// Get current price for a specific coin
    func getCurrentPrice(for coinId: String) -> Decimal? {
        return currentPrices[coinId]
    }
    
    // BUY COINS - Add new purchase to portfolio
    func addToPortfolio(coinId: String, coinSymbol: String, quantity: Decimal, purchasePrice: Decimal, imageUrl: String) async {
        guard let userId = authService.userSession?.uid else {
            lastError = .userNotAuthenticated
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let date = Date()
            
            // 1. CREATE TRANSACTION RECORD
            let transaction = Transaction(
                coinId: coinId,
                coinSymbol: coinSymbol,
                quantity: quantity,
                price: purchasePrice,
                type: .buy,
                date: date,
                imageUrl: imageUrl
            )
            
            // 2. UPDATE OR CREATE HOLDING
            if let existingIndex = holdings.firstIndex(where: { $0.coinId == coinId }) {
                // Update existing holding with new average price
                let existingHolding = holdings[existingIndex]
                let newTotalInvested = existingHolding.totalInvested + (quantity * purchasePrice)
                let newQuantity = existingHolding.quantity + quantity
                let newAveragePrice = newTotalInvested / newQuantity
                
                // Update the existing holding properly
                holdings[existingIndex].quantity = newQuantity
                holdings[existingIndex].averagePurchasePrice = newAveragePrice
                holdings[existingIndex].totalInvested = newTotalInvested
                holdings[existingIndex].lastPurchaseDate = date
            } else {
                // Create new holding
                let newHolding = Holding(
                    coinId: coinId,
                    coinSymbol: coinSymbol,
                    quantity: quantity,
                    purchasePrice: purchasePrice,
                    date: date,
                    imageUrl: imageUrl
                )
                holdings.append(newHolding)
            }
            
            // 3. SAVE TO FIRESTORE ATOMICALLY
            // Find the holding we just updated/created (guaranteed to exist)
            guard let updatedHolding = holdings.first(where: { $0.coinId == coinId }) else {
                throw NSError(domain: "PortfolioError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to find updated holding"])
            }
            
            // Use atomic operation to save both transaction and holding
            try await firestoreService.saveTransactionAndHolding(
                userId: userId, 
                transaction: transaction, 
                holding: updatedHolding
            )
            
            // Update local state
            transactions.append(transaction)
            lastError = nil
            
        } catch {
            lastError = .transactionFailed
        }
    }
    
    // REMOVE HOLDING - Delete entire holding from portfolio
    func removeFromPortfolio(_ holding: Holding) async {
        guard let userId = authService.userSession?.uid else {
            lastError = .userNotAuthenticated
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await firestoreService.deleteHolding(userId: userId, coinId: holding.coinId)
            holdings.removeAll { $0.id == holding.id }
            lastError = nil
        } catch {
            lastError = .firestoreSaveFailed
        }
    }
    
    // FIFO SELLING - Sell coins using First In, First Out method
    func sellFromPortfolio(coinId: String, quantityToSell: Decimal) async -> Bool {
        guard let userId = authService.userSession?.uid else {
            lastError = .userNotAuthenticated
            return false
        }
        
        guard let holdingIndex = holdings.firstIndex(where: { $0.coinId == coinId }) else {
            lastError = .holdingNotFound
            return false
        }
        
        guard quantityToSell <= holdings[holdingIndex].quantity else {
            lastError = .insufficientHoldings
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Get current market price for selling
            let currentPrice = getCurrentPrice(for: coinId) ?? holdings[holdingIndex].averagePurchasePrice
            
            // Create sell transaction
            let sellTransaction = Transaction(
                coinId: coinId,
                coinSymbol: holdings[holdingIndex].coinSymbol,
                quantity: quantityToSell,
                price: currentPrice,
                type: .sell,
                date: Date(),
                imageUrl: holdings[holdingIndex].imageUrl
            )
            
            // Update holding quantity
            holdings[holdingIndex].quantity -= quantityToSell
            holdings[holdingIndex].totalInvested -= (quantityToSell * holdings[holdingIndex].averagePurchasePrice)
            
            // If quantity becomes zero or negative, remove holding
            if holdings[holdingIndex].quantity <= 0 {
                try await firestoreService.deleteHolding(userId: userId, coinId: coinId)
                holdings.remove(at: holdingIndex)
            } else {
                try await firestoreService.saveHolding(userId: userId, holding: holdings[holdingIndex])
            }
            
            // Save sell transaction
            try await firestoreService.saveTransaction(userId: userId, transaction: sellTransaction)
            transactions.append(sellTransaction)
            
            lastError = nil
            return true
            
        } catch {
            lastError = .transactionFailed
            return false
        }
    }
    
    func getTotalHolding(for coinId: String) -> Decimal {
        holdings.first(where: { $0.coinId == coinId })?.quantity ?? 0
    }
    
    // PORTFOLIO CALCULATIONS - Using live market prices
    func totalPortfolioValue() -> Decimal {
        holdings.reduce(0) { total, holding in
            let currentPrice = currentPrices[holding.coinId] ?? holding.averagePurchasePrice
            return total + holding.currentValue(currentPrice: currentPrice)
        }
    }
    
    func totalInvestment() -> Decimal {
        holdings.reduce(0) { total, holding in
            total + holding.totalInvested
        }
    }
    
    func totalProfitLoss() -> Decimal {
        return totalPortfolioValue() - totalInvestment()
    }
    
    func totalProfitLossPercentage() -> Decimal {
        let investment = totalInvestment()
        guard investment > 0 else { return 0 }
        
        let currentValue = totalPortfolioValue()
        return ((currentValue - investment) / investment) * 100
    }
    
    var holdingsCount: Int {
        holdings.count
    }
    
    var transactionCount: Int {
        transactions.count
    }
    
    // DEINITIALIZER - Clean up (no NotificationCenter observers needed)
    deinit {
        // No cleanup needed with @Observable pattern
    }
}
