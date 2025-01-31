import SwiftUI
import FirebaseAuth
import LocalAuthentication
import KeychainSwift

enum NavigationDestination: Hashable {
    case profile
    case registration
}

struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 20) {
                Text("Log In")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                
                CustomTextField(
                    icon: "envelope",
                    placeholder: "Email",
                    text: $email
                )
                              
                CustomTextField(
                    icon: "lock",
                    placeholder: "Password",
                    text: $password
                )
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 20)
            
            VStack(spacing: 20) {
                Login_RegisterButton(
                    text: "Log in",
                    backgroundColor: .black.opacity(0.8),
                    foregroundColor: .white,
                    action: { authViewModel.login(email: email, password: password)
                    })
                
                
                Login_RegisterButton(
                    text: "Log in with Face ID",
                    backgroundColor: .yellow.opacity(0.5),
                    foregroundColor: .white,
                    action: { authViewModel.authenticateWithFaceID()
                    })
                
                DividerView()
            
                Login_RegisterButton(
                    text: "Sign Up",
                    backgroundColor: .white,
                    foregroundColor: .gray,
                    action: { navigationPath.append(NavigationDestination.registration)
                    })
                
                if authViewModel.showError {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
            .navigationDestination(
                for: NavigationDestination.self
            ) { destination in
                switch destination {
                case .profile:
                    ProfileView(
                        authViewModel: authViewModel,
                        handleLogout: {
                            Task {
                                try? await authViewModel.signOut()
                                navigationPath.removeLast()
                            }
                        }
                    )
                case .registration:
                    RegistrationView(authViewModel: authViewModel)
                }
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
            if newValue {
                navigationPath.append(NavigationDestination.profile)
            }
        }
    }
}

#Preview {
    LoginView()
}

