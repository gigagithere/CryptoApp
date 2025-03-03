//
//  ContentViewModel.swift
//  CryptoApp
//
//  Created by Bartosz Mrugała on 03/03/2025.
//

import Foundation
import Combine
import FirebaseAuth



@MainActor
class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        AuthService.shared.$userSession.sink{ [weak self] userSession in
            self?.userSession = userSession
        }.store(in: &cancellables)
    }
}
