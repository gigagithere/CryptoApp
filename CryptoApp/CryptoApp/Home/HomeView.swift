//
//  HomeView.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 26/08/2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var homeVM: HomeViewModel
    @StateObject var topMoversVM: TopMoversViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TopMoversView(topMoversVM: topMoversVM)
                        .frame(height: 150)
                        .padding()
                    
                    Divider()
                    
                    CustomSearchBar(text: $homeVM.searchText)
                        .padding(.top, 10)
                        
                    
                    AllCoinsView(homeVM: homeVM)
                }
            }
            .navigationTitle("Live Prices")
            .onAppear {
                Task {
                    await homeVM.fetchData()
                    topMoversVM.updateTopMovers(from: homeVM.coins)
                }
            }
        }
    }
}

#Preview {
    HomeView(homeVM: HomeViewModel(), topMoversVM: TopMoversViewModel())
}
