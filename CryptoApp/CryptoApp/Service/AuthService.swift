import SwiftUI
import FirebaseAuth


@MainActor
class AuthService: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func login(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            print("DEBUG: Login user \(result.user.uid)")
        }
        catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
        }
    }
    
        func createUser(email: String, password: String) async throws {
            do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                self.userSession = result.user
                print("DEBUG: Created user \(result.user.uid)")
            }
            
            catch {
                print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            }
        }
        
        func signOut() async throws {
            try? Auth.auth().signOut()
            self.userSession = nil
        }
    
    
    
}
