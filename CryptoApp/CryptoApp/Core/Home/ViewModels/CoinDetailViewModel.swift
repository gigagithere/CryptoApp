//
//  CoinDetailView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 31/01/2025.
//

import Foundation

class CoinDetailViewModel: ObservableObject {
    @Published var priceHistory: [(time: Date, price: Double)] = []
    @Published var isLoading: Bool = false

    func fetchHistoricalData(for coinId: String, days: Int) {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinId)/market_chart?vs_currency=usd&days=\(days)") else {
            print("Invalid URL")
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(HistoricalPriceData.self, from: data)
                DispatchQueue.main.async {
                    self.priceHistory = decodedData.prices.map { dataPoint in
                        let timestamp = dataPoint[0] / 1000 // Timestamp in seconds
                        let price = dataPoint[1] // Price
                        return (time: Date(timeIntervalSince1970: timestamp), price: price)
                    }
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
}
