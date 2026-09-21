//
//  ProfileView.swift
//  CryptoApp
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @AppStorage("appTheme") private var theme: AppTheme = .system
    @ScaledMetric(relativeTo: .largeTitle) private var avatarSize: CGFloat = 110
    @State private var signOutError = ""
    @State private var showSignOutError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: Spacing.l) {
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
                        .shadow(color: .purple.opacity(0.35), radius: 10, x: 0, y: 5)
                        .accessibilityHidden(true)
                    
                    Text(authService.accountName)
                        .font(.title2)
                        .bold()
                }

                VStack(spacing: Spacing.l) {
                    HStack {
                        Text("SETTINGS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: Spacing.m) {
                        Label("Appearance", systemImage: "moon.stars")
                        
                        Picker("Appearance", selection: $theme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.title).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(Spacing.m)
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: Radius.medium))
                }

                Button {
                    do {
                        try authService.signOut()
                    } catch {
                        signOutError = error.localizedDescription
                        showSignOutError = true
                    }
                } label: {
                    Label("Logout", systemImage: "arrow.uturn.backward")
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red.opacity(0.08), in: .rect(cornerRadius: Radius.medium))
                }
            }
            .padding(Spacing.xl)
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
