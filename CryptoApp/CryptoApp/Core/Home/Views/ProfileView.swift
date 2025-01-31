import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let handleLogout: () -> Void
    @State private var isPushNotificationsOn: Bool = true
    @State private var isFaceIdOn: Bool = true
   @AppStorage("isDarkModeOn") private var isDarkModeOn: Bool = false


    var body: some View {
        VStack {
            // Header z informacjami użytkownika
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.black.opacity(0.9))
                
                Text(authViewModel.userEmail.isEmpty ? "Loading..." : authViewModel.userEmail)
                .font(.title2)
                .bold()
                .padding(.bottom)
                
                Button(action: {
                    print("Edit profile tapped")
                }) {
                    Text("Edit profile")
                        .frame(width: 130, height: 40)
                        .buttonBorderShape(.capsule)
                        .background(Color.yellow.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .padding(20)
            
            // Lista ustawień i przycisk wylogowania
            List {
                Section(header: Text("Settings")) {
                    Toggle(isOn: $isPushNotificationsOn) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.orange)
                            Text("Push notifications")
                        }
                    }
                    Toggle(isOn: $isFaceIdOn) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundColor(.purple)
                            Text("Face ID")
                        }
                    }
                    Toggle(isOn: $isDarkModeOn) {
                        HStack {
                            Image(systemName: "moon.stars")
                                .foregroundColor(.yellow)
                            Text("DarkMode")
                        }
                    }
                    
                    NavigationLink(destination: Text("PIN Code")) {
                        HStack {
                            Image(systemName: "key")
                                .foregroundColor(.gray)
                            Text("PIN Code")
                        }
                    }
                    NavigationLink(destination: Text("Support")) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                            Text("Support")
                        }
                    }
                }
                
                // Przycisk Logout
                Button(action: {
                    logoutUser()
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.red)
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .preferredColorScheme(isDarkModeOn ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $authViewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(authViewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func logoutUser() {
        Task {
            do {
                try await authViewModel.signOut()
                handleLogout() // Powiadomienie nadrzędnego widoku o wylogowaniu
            } catch {
                authViewModel.showError = true
                authViewModel.errorMessage = "Failed to log out: \(error.localizedDescription)"
            }
        }
    }
}
#Preview {
    ProfileView(authViewModel: AuthViewModel(), handleLogout: {})
}
