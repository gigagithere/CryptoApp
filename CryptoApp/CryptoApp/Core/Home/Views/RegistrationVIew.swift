import SwiftUI

struct RegistrationView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Register")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
            
            CustomTextField(icon: "lock", placeholder: "Password", text: $password)
        }
        .padding(.vertical, 50)
        .padding(.horizontal, 20)
        
        VStack(spacing: 20) {
            Login_RegisterButton(
                text: "Sign Up",
                backgroundColor: .yellow.opacity(0.5),
                foregroundColor: .white,
                action: { authViewModel.register(email: email, password: password) }
            )
            
            DividerView()
            
            Login_RegisterButton(
                text: "Back to log in",
                backgroundColor: .white,
                foregroundColor: .gray.opacity(0.8),
                action: { }
            )
            
            if authViewModel.showError {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

#Preview {
    RegistrationView(authViewModel: AuthViewModel())
}
