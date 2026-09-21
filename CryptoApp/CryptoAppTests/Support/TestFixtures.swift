//
//  TestFixtures.swift
//  CryptoAppTests
//

import Foundation
@testable import CryptoApp

enum TestFixtures {
    /// A coin decoded from the minimal JSON CoinGecko fields the app requires.
    static func coin(id: String, price: Double) throws -> Coin {
        let json = #"{"id":"\#(id)","symbol":"\#(id)","name":"\#(id.capitalized)","image":"https://example.com/\#(id).png","current_price":\#(price)}"#
        return try JSONDecoder().decode(Coin.self, from: Data(json.utf8))
    }
}
