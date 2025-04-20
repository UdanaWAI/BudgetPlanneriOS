import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var errorMessage = ""
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextBox(text: $email, placeholder: "Enter your email", lable: "Email")

            PasswordField(password: $password, placeholder: "Enter your password", label: "Password")

            CheckboxView(isChecked: $rememberMe, label: "Remember me")

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            PrimaryButton(title: "Login") {
                authVM.login(email: email, password: password) { error in
                    if let error = error {
                        self.errorMessage = error
                    }
                }
            }

            Spacer()

            HStack {
                Text("Don't have an account?")
                NavigationLink("Sign up", destination: RegisterView())
            }
            .font(.footnote)
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
        }
    }
}
