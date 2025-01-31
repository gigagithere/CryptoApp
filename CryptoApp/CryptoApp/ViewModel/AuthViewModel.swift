import FirebaseAuth
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserModel?
    @Published var error: AuthenticationError?
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func login(email: String, password: String) {
        Task {
            do {
                currentUser = try await authService.login(email: email, password: password)
                isAuthenticated = true
            } catch {
                handleError(error)
            }
        }
    }
    
    func register(email: String, password: String) {
        Task {
            do {
                currentUser = try await authService.register(email: email, password: password)
                isAuthenticated = true
            } catch {
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        self.error = error as? AuthenticationError ?? .unknown
        self.errorMessage = error.localizedDescription
        self.showError = true
    }
} 