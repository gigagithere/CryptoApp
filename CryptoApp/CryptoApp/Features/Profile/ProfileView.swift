//
//  ProfileView.swift
//  CryptoApp
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @AppStorage("appTheme") private var theme: AppTheme = .system
    @ScaledMetric(relativeTo: .largeTitle) private var avatarSize: CGFloat = 96
    @State private var showLogoutConfirmation = false
    @State private var signOutError = ""
    @State private var showSignOutError = false

    var body: some View {
        List {
            Section {
                VStack(spacing: Spacing.m) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: avatarSize * 0.55)) // scales with the avatar, which scales with Dynamic Type
                        .foregroundStyle(.white)
                        .frame(width: avatarSize, height: avatarSize)
                        .background(
                            LinearGradient(
                                colors: [.customDarkBlue, .customBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.circle)
                        .accessibilityHidden(true)

                    Text(authService.accountName)
                        .font(.title2)
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.s)
                .listRowBackground(Color.clear)
            }

            Section("Appearance") {
                Picker("Appearance", selection: $theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.title).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button("Log Out", systemImage: "arrow.uturn.backward", role: .destructive) {
                    showLogoutConfirmation = true
                }
                .foregroundStyle(.red)
                // Attached to the button that triggers it, so the dialog animates out of the right place
                .confirmationDialog("Log out of CryptoApp?", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                    Button("Log Out", role: .destructive, action: logOut)
                }
            }
        }
        .navigationTitle("Profile")
        .alert("Couldn't log out", isPresented: $showSignOutError) { } message: {
            Text(signOutError)
        }
    }

    private func logOut() {
        do {
            try authService.signOut()
        } catch {
            signOutError = error.localizedDescription
            showSignOutError = true
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .previewEnvironment()
}
