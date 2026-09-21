import SwiftUI
import FirebaseAuth

// MARK: - UIKit Image Picker Wrapper
struct UIKitImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: UIKitImagePicker
        init(parent: UIKitImagePicker) { self.parent = parent }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.selectedImage = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.selectedImage = original
            }
            parent.dismiss()
        }
    }
}

// MARK: - Add Photo Button (Avatar)
struct AddPhotoButton: View {
    @Binding var image: UIImage?
    @State private var showingPicker = false
    @Environment(\.colorScheme) private var colorScheme

    private var defaultUserIcon: String {
        "person.circle.fill"
    }

    var body: some View {
        ZStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(.white, lineWidth: 3))
                    .shadow(radius: 6)
                    .overlay(
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 30, height: 30)
                            Image(systemName: "pencil")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .offset(x: 35, y: 35)
                    )
                    .onTapGesture { showingPicker = true }
            } else {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.customDarkBlue, .customBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .shadow(color: .purple.opacity(0.35), radius: 10, x: 0, y: 5)

                    Image(systemName: defaultUserIcon)
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(radius: 2)
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.customBlue)
                    }
                    .offset(x: 35, y: 35)
                }
                .onTapGesture { showingPicker = true }
            }
        }
        .sheet(isPresented: $showingPicker) {
            UIKitImagePicker(selectedImage: $image)
        }
        .animation(.easeInOut, value: image)
    }
}

// MARK: - Badge for add/change
struct ProfileView: View {
    @State private var authService = AuthService.shared  // ✨ Own its auth state
    @Environment(\.dismiss) private var dismiss

    @State private var isPushNotificationsOn: Bool = true
    @State private var isFaceIdOn: Bool = true
    @AppStorage("isDarkModeOn") private var isDarkModeOn: Bool = false
    @State private var profileImage: UIImage? = nil
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
                    AddPhotoButton(image: $profileImage)
                    
                    Text(displayName)
                        .font(.title2)
                        .bold()
                    
                    Login_RegisterButton(text: "Edit Profile", backgroundColor:Color.customDarkBlue.opacity(0.85), foregroundColor: .white, action: { /* TODO: Implement edit profile */ })
                        .padding(.horizontal, 130)
                }

                // Settings section
                VStack(spacing: 16) {
                    SectionHeader(title: "Settings")

                    VStack(spacing: 1) {
                        SettingRow(icon: "bell", iconColor: .orange, title: "Push Notifications", control: {
                            Toggle("", isOn: $isPushNotificationsOn)
                                .labelsHidden()
                        })
                        SettingRow(icon: "faceid", iconColor: .purple, title: "Face ID", control: {
                            Toggle("", isOn: $isFaceIdOn)
                                .labelsHidden()
                        })
                        SettingRow(icon: "moon.stars", iconColor: .yellow, title: "Dark Mode", control: {
                            Toggle("", isOn: $isDarkModeOn)
                                .labelsHidden()
                        })
                        NavigationLink {
                            Text("PIN Code")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemBackground))
                        } label: {
                            SettingRow(icon: "key", iconColor: .gray, title: "PIN Code", control: {
                                EmptyView()
                            })
                        }
                        NavigationLink {
                            Text("Support")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemBackground))
                        } label: {
                            SettingRow(icon: "questionmark.circle", iconColor: .blue, title: "Support", control: {
                                EmptyView()
                            })
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Logout
                VStack(spacing: 8) {
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
                                .foregroundColor(.red)
                            Text("Logout")
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
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

// MARK: - Supporting small components
struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct SettingRow<Control: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let control: () -> Control

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            Text(title)
                .font(.body)
            Spacer()
            control()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileView()  // ✨ Clean - owns its own state
    }
    .preferredColorScheme(.light)
}
