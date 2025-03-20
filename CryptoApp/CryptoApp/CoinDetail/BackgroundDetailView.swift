//
//  BackgroundDetailView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 18/03/2025.
//

import SwiftUI
import Kingfisher

struct BackgroundDetailView: View {
    let coin: Coin

    var body: some View {
        GeometryReader { geometry in
            KFImage(URL(string: coin.image))
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .blur(radius: 250)
                .offset(y: geometry.size.height * 0.7)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundDetailView(coin: Coin.sample)
}
