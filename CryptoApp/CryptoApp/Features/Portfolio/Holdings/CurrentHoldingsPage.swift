//
//  CurrentHoldingsPage.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import SwiftUI

struct CurrentHoldingsPage: View {
    @Environment(PortfolioViewModel.self) private var portfolio
    
    var body: some View {
        Group {
            if portfolio.holdings.isEmpty {
                ContentUnavailableView(
                    "No Holdings Yet",
                    systemImage: "bitcoinsign.circle",
                    description: Text("Start trading to build your portfolio")
                )
            } else {
                VStack {
                    HStack {
                        LabeledValue(title: "Total Holdings") {
                            Text(portfolio.holdings.count, format: .number)
                                .font(.title2)
                                .bold()
                        }
                        
                        Spacer()
                        
                        LabeledValue(title: "Portfolio Value", alignment: .trailing) {
                            Text(portfolio.totalPortfolioValue(), format: .usd)
                                .font(.title2)
                                .bold()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(portfolio.holdings) { holding in
                                CurrentHoldingsRowView(
                                    holding: holding,
                                    currentPrice: portfolio.currentPrice(for: holding)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .safeAreaPadding(.bottom)
                    }
                }
            }
        }
        .navigationTitle("Current Holdings")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        CurrentHoldingsPage()
            .routeDestinations()
    }
    .previewEnvironment()
}
