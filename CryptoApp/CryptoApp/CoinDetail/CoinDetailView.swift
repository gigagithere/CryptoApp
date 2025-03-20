import SwiftUI
import Kingfisher

struct CoinDetailView: View {
    let coin: Coin
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ChartView(coin: coin)
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Overview")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        Divider()
                        
                        HStack(spacing: 15) {
                            InfoItemView(
                                title: "Current Price",
                                value: coin.currentPrice.toCurrency(),
                                footnote: coin.priceChangePercentage24H.toPercentString()
                            )
                            InfoItemView(
                                title: "Market Capitalization",
                                value: (coin.marketCap ?? 0).toAbbreviatedString(),
                                footnote: (coin.marketCapChangePercentage24H ?? 0).toPercentString()
                            )
                        }
                        .padding(.horizontal, 15)
                        
                        HStack(spacing: 15) {
                            InfoItemView(
                                title: "Rank",
                                value: "\(coin.marketCapRank)",
                                footnote: nil
                            )
                            InfoItemView(
                                title: "Volume",
                                value: (coin.totalVolume ?? 0).toAbbreviatedString(),
                                footnote: "4%"
                            )
                        }
                        .padding(.horizontal, 15)
                    }
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Additional Details")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        Divider()
                        
                        HStack(spacing: 15) {
                            InfoItemView(
                                title: "ATH",
                                value: (coin.ath ?? 0).toCurrency(),
                                footnote: coin.athDate?.asFormattedDate
                            )
                            InfoItemView(
                                title: "ATL",
                                value: (coin.atl ?? 0).toCurrency(),
                                footnote: coin.atlDate?.asFormattedDate
                            )
                        }
                        .padding(.horizontal, 15)
                    }
                }
                .background(BackgroundDetailView(coin: coin))
                .navigationTitle(coin.name)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Text(coin.symbol.uppercased())
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            KFImage(URL(string: coin.image))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 20) {
                    Login_RegisterButton(
                        text: "Buy",
                        backgroundColor: .green,
                        foregroundColor: .white
                    ) {
                        print("buy")
                    }         
                    Login_RegisterButton(
                        text: "Sell",
                        backgroundColor: .red,
                        foregroundColor: .white
                    ) {
                        print("sell")
                    }
                }
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 10)
                .padding(.horizontal, 25)
            }
        }
    }
}

#Preview {
    CoinDetailView(coin: Coin.sample)
}
