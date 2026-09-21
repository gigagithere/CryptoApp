//
//  ProfileView.swift
//  CryptoApp
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @AppStorage("isDarkModeOn") private var isDarkModeOn: Bool = false
    @State private var signOutError = ""
    @State private var showSignOutError = false

    private var displayName: String {
        if let user = authService.userSession {
            if let name = user.displayName, !name.isEmpty {
                return name
            } else if let email = user.email {
                return email
            }
        }
        return "User"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                        .frame(width: 110, height: 110)
                        .background(
                            LinearGradient(
                                colors: [.customDarkBlue, .customBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .purple.opacity(0.35), radius: 10, x: 0, y: 5)
                    
                    Text(displayName)
                        .font(.title2)
                        .bold()
                }

                // Settings section
                VStack(spacing: 16) {
                    HStack {
                        Text("SETTINGS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    Toggle(isOn: $isDarkModeOn) {
                        Label("Dark Mode", systemImage: "moon.stars")
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }

                // Logout
                Button {
                    do {
                        try authService.signOut()
                    } catch {
                        signOutError = error.localizedDescription
                        showSignOutError = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundStyle(.red)
                        Text("Logout")
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 12))
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.automatic)
        .alert("Couldn't log out", isPresented: $showSignOutError) {
            Button("OK") { }
        } message: {
            Text(signOutError)
        }
        .tint(.customDarkBlue.opacity(0.8))
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .previewEnvironment()
}
