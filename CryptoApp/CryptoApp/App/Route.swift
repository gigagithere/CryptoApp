//
//  Route.swift
//  CryptoApp
//

import SwiftUI

/// Every screen a `NavigationLink(value:)` can push.
enum Route: Hashable {
    case coin(id: String)
    case holdings
    case transactions
}

extension View {
    /// Tells the surrounding `NavigationStack` how to build each `Route`.
    func routeDestinations() -> some View {
        navigationDestination(for: Route.self) { route in
            switch route {
            case .coin(let id):
                CoinDetailView(coinID: id)
            case .holdings:
                CurrentHoldingsPage()
            case .transactions:
                TransactionHistoryPage()
            }
        }
    }
}
