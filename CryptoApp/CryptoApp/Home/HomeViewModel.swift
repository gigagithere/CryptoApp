import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var coins: [Coin] = [] {
        didSet { updateFilteredCoins() }
    }
    @Published var searchText: String = "" {
        didSet { updateFilteredCoins() }
    }
    
    @Published private(set) var filteredCoins: [Coin] = []
    
    private let repository: CoinRepositoryProtocol = CoinRepository()
    
    func fetchData() async {
        do {
            coins = try await repository.fetchCoins()
        } catch {
            print("Error fetching coins: \(error.localizedDescription)")
        }
    }
    
    private func updateFilteredCoins() {
        if searchText.isEmpty {
            filteredCoins = coins
        } else {
            filteredCoins = coins.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}
