import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthService
    @Environment(\.dismiss) private var dismiss
    
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
                    .foregroundColor(.customDarkBlue.opacity(0.8))
                
                Text("hrr")
                    .font(.title2)
                    .bold()
                    .padding(.bottom)
                
                Login_RegisterButton(
                    text: "Edit Profile",
                    backgroundColor: .customDarkBlue.opacity(0.8),
                    foregroundColor: .white,
                    action: {})
                
                    
                .padding(.horizontal, 100)
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
                Button(action: { Task { try await AuthService.shared.signOut()} }) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.red)
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
            }
            .scrollDisabled(true)
        }  .preferredColorScheme(isDarkModeOn ? .dark : .light)
            .tint(.customDarkBlue.opacity(0.8))
    }
      
}
    
#Preview {
    ProfileView(authViewModel: AuthService() )
}
