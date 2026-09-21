//
//  CoinDecodingTests.swift
//  CryptoAppTests
//

import Foundation
import Testing
@testable import CryptoApp

struct CoinDecodingTests {
    private let minimalCoin = #"{"id":"a","symbol":"a","name":"A","image":"x","current_price":1.5}"#
    
    /// Regression: CoinGecko returned `null` for these fields for one coin, which used to
    /// fail decoding of the whole list and left the coin screen empty.
    @Test func nullNumericFieldsDecodeAsZero() throws {
        let json = """
        {"id":"figure-heloc","symbol":"figr","name":"Figure Heloc","image":"x","current_price":1.0,
         "market_cap_rank":null,"price_change_24h":null,"price_change_percentage_24h":null,"ath_change_percentage":null}
        """
        let coin = try JSONDecoder().decode(Coin.self, from: Data(json.utf8))
        
        #expect(coin.currentPrice == 1.0)
        #expect(coin.priceChange24H == 0)
        #expect(coin.priceChangePercentage24H == 0)
        #expect(coin.marketCapRank == 0)
        #expect(coin.athChangePercentage == 0)
    }
    
    @Test func optionalFieldsMayBeMissing() throws {
        let coin = try JSONDecoder().decode(Coin.self, from: Data(minimalCoin.utf8))
        
        #expect(coin.marketCap == nil)
        #expect(coin.sparklineIn7D == nil)
    }
    
    @Test func oneMalformedCoinDoesNotDropTheList() throws {
        // The middle entry has no price, which is the one field a coin can't do without
        let json = "[\(minimalCoin), {\"id\":\"broken\"}, \(minimalCoin.replacing("\"a\"", with: "\"b\""))]"
        
        let coins = try CoinRepository.decodeCoins(from: Data(json.utf8))
        
        #expect(coins.map(\.id) == ["a", "b"])
    }
    
    @Test func rateLimitErrorObjectIsNotMistakenForCoins() {
        let json = #"{"status":{"error_code":429,"error_message":"Rate limit"}}"#
        
        #expect(throws: DecodingError.self) {
            try CoinRepository.decodeCoins(from: Data(json.utf8))
        }
    }
}
