//
//  TradeViewModel.swift
//  CryptoApp
//
//  State and logic of the buy / sell sheet.
//

import Foundation
import Observation

@Observable
final class TradeViewModel {
    /// Quick-pick amounts under the quantity field
    static let presets: [Decimal] = [0.1, 0.5, 1, 5]

    let coinID: String
    let type: TransactionType
    /// The most that can be traded: what you own, when selling. nil means no limit (buying).
    let maxQuantity: Decimal?
    /// Bound to the quantity field; nil while the field is empty or isn't a number.
    var quantity: Decimal?
    private(set) var isProcessing = false

    init(coinID: String, type: TransactionType, quantity: Decimal? = 1, maxQuantity: Decimal? = nil) {
        self.coinID = coinID
        self.type = type
        self.quantity = quantity
        self.maxQuantity = maxQuantity
    }

    var quantityValue: Decimal {
        quantity ?? 0
    }

    /// True when the entered amount is more than can be sold.
    var exceedsMax: Bool {
        guard let maxQuantity else { return false }
        return quantityValue > maxQuantity
    }

    var canSubmit: Bool {
        quantityValue > 0 && !exceedsMax && !isProcessing
    }

    func total(at price: Decimal) -> Decimal {
        quantityValue * price
    }

    /// Buys or sells the entered quantity at the live market price. Throws a `PortfolioError`.
    func execute(using portfolio: PortfolioViewModel) async throws {
        guard canSubmit else {
            throw exceedsMax ? PortfolioError.insufficientHoldings : PortfolioError.invalidQuantity
        }

        isProcessing = true
        defer { isProcessing = false }

        switch type {
        case .buy:
            try await portfolio.buy(coinId: coinID, quantity: quantityValue)
        case .sell:
            try await portfolio.sell(coinId: coinID, quantity: quantityValue)
        }
    }
}
