import SwiftUI
import FirebaseAuth
import LocalAuthentication
import KeychainSwift

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var userEmail: String = ""
    private let keychain = KeychainSwift()
    
    // MARK: - Logowanie za pomocą emaila i hasła
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            showError = true
            errorMessage = "Email and password cannot be empty."
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) {
                [weak self] result,
                error in
                guard let self = self else { return }
                if let error = error {
                    self.showError = true
                    self.errorMessage = error.localizedDescription
                } else {
                    self.isAuthenticated = true
                    self.userEmail = email
                    self.showError = false
                
                    // Zapisz eamil i haslo w kecyhain
                    self.keychain.set(email, forKey: "userEmail")
                    self.keychain.set(password, forKey: "userPassword")
                    print("✅ Dane logowania zapisane w Keychain.")
                }
            }
    }
    // MARK: - Logowanie za pomocą Face ID
    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,localizedReason: "Zaloguj się za pomocą Face ID") { success, authenticationError in
                    if success {
//                        DispatchQueue.main.async {
                            guard let savedEmail = self.keychain.get(
                                "userEmail"
                            ),
                                  let savedPassword = self.keychain.get("userPassword") else {
                                self.showError = true
                                self.errorMessage = "Brak zapisanych danych logowania w Keychain."
                                print("❌ Brak danych logowania w Keychain.")
                                return
                            }

                            print(
                                "✅ Odczytano dane logowania z Keychain: \(savedEmail) / \(savedPassword)"
                            )

                            // Logowanie za pomocą zapisanych danych
                            self.login(
                                email: savedEmail,
                                password: savedPassword
                            )
//                        }
                    } else {
//                        DispatchQueue.main.async {
                            self.showError = true
                            self.errorMessage = authenticationError?.localizedDescription ?? "Nieznany błąd biometryczny."
//                        }
                    }
                }
        } else {
//            DispatchQueue.main.async {
                self.showError = true
                self.errorMessage = "Face ID nie jest dostępne na tym urządzeniu."
//            }
        }
    }
    // MARK: - Rejestracja nowego użytkownika
    func register(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            showError = true
            errorMessage = "Email and password cannot be empty."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                if let error = error {
//                    DispatchQueue.main.async {
                        self.showError = true
                        self.errorMessage = error.localizedDescription
//                    }
                } else {
//                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        self.userEmail = email
                        self.showError = false
//                    }
                    // Zapisz eamil i haslo w kecyhain
                    self.keychain.set(email, forKey: "userEmail")
                    self.keychain.set(password, forKey: "userPassword")
                    print("✅ Dane logowania zapisane w Keychain.")
                }
            }
    }
    
    // MARK: - Wylogowanie użytkownika
    func signOut() async throws {
        try Auth.auth().signOut()
        self.isAuthenticated = false
        userEmail = ""
    }
}
    

