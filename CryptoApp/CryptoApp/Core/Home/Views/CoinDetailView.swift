//
//  CoinDetailView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 31/01/2025.
//

import SwiftUI
import Charts

struct CoinDetailView: View {
    let coin: Coin
    @StateObject private var viewModel = CoinDetailViewModel()
    @State private var selectedDays: Int = 7

    var body: some View {
        VStack {
            Picker("Select Timeframe", selection: $selectedDays) {
                Text("1 Day").tag(1)
                Text("7 Days").tag(7)
                Text("30 Days").tag(30)
                Text("365 Days").tag(365)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if viewModel.isLoading {
                ProgressView()
            } else {
                PriceChart(priceHistory: viewModel.priceHistory)
            }
        }
        .onAppear {
            viewModel.fetchHistoricalData(for: coin.id, days: selectedDays)
        }
        .onChange(of: selectedDays) { oldDays, newDays in
            viewModel.fetchHistoricalData(for: coin.id, days: newDays)
        }
    }
}
