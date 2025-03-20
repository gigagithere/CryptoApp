import SwiftUI

struct AllCoinsView: View {
    @ObservedObject var homeVM: HomeViewModel
    
    @State private var selectedSortOption: SortOption = .marketCap
    @State private var sortOrder: SortOrder = .descending
    
    private var sortedCoins: [Coin] {
         var coins = homeVM.filteredCoins
         switch selectedSortOption {
         case .price:
             coins.sort { sortOrder == .ascending ? $0.currentPrice < $1.currentPrice : $0.currentPrice > $1.currentPrice }
         case .marketCap:
             coins.sort { sortOrder == .ascending ? ($0.marketCap ?? 0) < ($1.marketCap ?? 0) : ($0.marketCap ?? 0) > ($1.marketCap ?? 0) }
         case .change:
             coins.sort { sortOrder == .ascending ? $0.priceChangePercentage24H < $1.priceChangePercentage24H : $0.priceChangePercentage24H > $1.priceChangePercentage24H }
         }
         return coins
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Coin List")
                .font(.headline)
                .padding()
            
            HStack {
                Text("Coin")
                
                Menu {
                    Section(header: Text("Sort Option")) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                selectedSortOption = option
                            } label: {
                                Label(option.rawValue, systemImage: option.iconName)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    Section(header: Text("Sort Order")) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button {
                                sortOrder = order
                            } label: {
                                Label(order.rawValue,
                                      systemImage: order == .ascending ? "arrow.up" : "arrow.down")
                                    .font(.caption)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption)
                        Text("\(selectedSortOption.rawValue) (\(sortOrder.rawValue))")
                            .font(.caption)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                }
                
                Text("Price")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal)
            
            ForEach(sortedCoins) { coin in
                NavigationLink(destination: CoinDetailView(coin: coin)) {
                    SingleRowView(coin: coin)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllCoinsView(homeVM: HomeViewModel())
    }
}
