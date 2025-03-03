import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var coins = [Coin]()
    @Published var topMovingCoins = [Coin]()

    let BASE_URL = "https://api.coingecko.com/api/v3/coins/"

    var urlString: String {
        return "\(BASE_URL)markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&price_change_percentage=24h"
    }

    func fetchData() async {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedCoins = try JSONDecoder().decode([Coin].self, from: data)
            self.coins = decodedCoins
            self.topMovingCoinsSorting()
        } catch {
            print("Unknown error: \(error.localizedDescription)")
        }
    }

    func topMovingCoinsSorting() {
        let topMovers = coins.sorted(by: { $0.priceChangePercentage24H > $1.priceChangePercentage24H })
        self.topMovingCoins = Array(topMovers.prefix(10))
    }
}
