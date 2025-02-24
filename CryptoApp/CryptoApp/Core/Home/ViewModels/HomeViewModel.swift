import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var coins = [Coin]()
    @Published var topMovingCoins = [Coin]()
    @Published var shouldRefresh = false // Flaga do kontrolowania odświeżania
    
    private var cancellables = Set<AnyCancellable>() // Przechowuje subskrypcje Combine
    
    let BASE_URL = "https://api.coingecko.com/api/v3/coins/"
    
    var urlString: String {
        return "\(BASE_URL)markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&price_change_percentage=24h"
    }
    
    init(useMockData: Bool = false) {
        if useMockData {
            // Użyj przykładowych danych podczas projektowania UI
            self.topMovingCoins = Array(repeating: Coin.sample, count: 10)
        } else {
            setupThrottling() // Konfiguracja throttlingu
        }
    }
    
    // Konfiguracja throttlingu
    private func setupThrottling() {
        // Obserwuj `shouldRefresh` i odśwież dane co 60 sekund
        $shouldRefresh
            .debounce(for: .seconds(60), scheduler: DispatchQueue.main) // Odświeżaj co 60 sekund
            .sink { [weak self] _ in
                self?.fetchCoinsWithURLSession()
            }
            .store(in: &cancellables)
    }
}

extension HomeViewModel {
    func fetchCoinsWithURLSession() {
        guard let url = URL(string: urlString) else {
            print("DEBUG: Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
                        
            DispatchQueue.main.async {
                if let error = error {
                    print("Error \(error)")
                    return
                }
                
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    print("Server error")
                    return
                }
                
                guard let data = data else {
                    print("Invalid data")
                    return
                }
                
                guard let coins = try? JSONDecoder().decode([Coin].self, from: data) else {
                    print("DEBUG: Invalid data")
                    return
                }
                            
                self.coins = coins
                self.topMovingCoinsSorting()
            }
        }.resume()
    }
    
    func topMovingCoinsSorting() {
        let topMovers = coins.sorted(by: { $0.priceChangePercentage24H > $1.priceChangePercentage24H })
        self.topMovingCoins = Array(topMovers.prefix(10))
    }
}
