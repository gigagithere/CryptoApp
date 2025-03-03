import SwiftUI
import FirebaseAuth

enum Route: Hashable {
    case registration
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var floatOffset: CGFloat = 0
    @State private var rotationAngle: CGFloat = 0
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Log In")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Your journey into the world of crypto starts here!")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .center, spacing: 20) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(40)
                        .frame(width: 180, height: 180)
                        .shadow(color: .gray, radius: 10, x: 7, y: 10)
                        .offset(y: floatOffset)
                        .rotationEffect(.degrees(rotationAngle))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.7)) {
                                rotationAngle += 360
                            }
                        }
                        .onAppear {
                            withAnimation(
                                Animation.easeInOut(duration: 3)
                                    .repeatForever(autoreverses: true)
                            ) {
                                floatOffset = -10
                            }
                        }
                    
                    Text("Please log in to continue")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    CustomTextField(
                        icon: "envelope",
                        placeholder: "Email",
                        text: $viewModel.email
                    )
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Password",
                        text: $viewModel.password
                    )
                    
                    Login_RegisterButton(
                        text: "Log in",
                        backgroundColor: .customDarkBlue,
                        foregroundColor: .white,
                        action: {
                            Task { try await viewModel.loginUser() }
                        }
                    )
                    
                    DividerView()
                    
                    Login_RegisterButton(
                        text: "Sign Up",
                        backgroundColor: .customDarkBlue.opacity(0.8),
                        foregroundColor: .white,
                        action: {
                            path.append(Route.registration)
                        }
                    )
                }
            }
            .padding()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .registration:
                    RegistrationView() // ✅ Teraz działa!
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
