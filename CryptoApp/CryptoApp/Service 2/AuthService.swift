protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> UserModel
    func register(email: String, password: String) async throws -> UserModel
    func signOut() async throws
}

class AuthService: AuthServiceProtocol {
    private let auth = Auth.auth()
    
    // ... istniejące metody ...
    
    func signOut() async throws {
        try auth.signOut()
    }
} 