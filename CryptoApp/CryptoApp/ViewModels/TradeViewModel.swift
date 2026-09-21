//
//  TradeViewModel.swift
//  CryptoApp
//
//  State and logic of the buy / sell sheet.
//

import Foundation
import Observation

@MainActor
@Observable
final class TradeViewModel {
    /// Quick-pick amounts under the quantity field
    static let presets: [Decimal] = [0.1, 0.5, 1, 5]

    let coinID: String
    let type: TransactionType
    /// Bound to the quantity field; nil while the field is empty or isn't a number.
    var quantity: Decimal? = 1
    private(set) var isProcessing = false

    init(coinID: String, type: TransactionType) {
        self.coinID = coinID
        self.type = type
    }

    var quantityValue: Decimal {
        quantity ?? 0
    }

    var canSubmit: Bool {
        quantityValue > 0 && !isProcessing
    }

    func total(at price: Decimal) -> Decimal {
        quantityValue * price
    }

    /// Buys or sells the entered quantity at the live market price. Throws a `PortfolioError`.
    func execute(using portfolio: PortfolioViewModel) async throws {
        guard canSubmit else { throw PortfolioError.invalidQuantity }

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
