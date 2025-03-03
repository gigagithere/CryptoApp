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

    var body: some View {
        VStack {
            Text(coin.name)
        }
    }
}
