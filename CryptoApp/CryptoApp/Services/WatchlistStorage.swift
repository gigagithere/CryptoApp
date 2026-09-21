//
//  WatchlistService.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import Foundation

protocol WatchlistStorageProtocol {
    func loadWatchedCoins() -> Set<String>
    func saveWatchedCoins(_ coinIds: Set<String>)
}

class WatchlistStorage: WatchlistStorageProtocol {
    private let userDefaultsKey = "WatchedCoins"
    
    func loadWatchedCoins() -> Set<String> {
        if let array = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            return Set(array)
        }
        return Set()
    }
    
    func saveWatchedCoins(_ coinIds: Set<String>) {
        let array = Array(coinIds)
        UserDefaults.standard.set(array, forKey: userDefaultsKey)
    }
}

