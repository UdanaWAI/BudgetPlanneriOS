import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var mobileNumber = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreeTerms = false
    @State private var errorMessage = ""
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextBox(text: $username, placeholder: "Enter your username", lable: "Username")

            TextBox(text: $mobileNumber, placeholder: "Enter your mobile number", lable: "Mobile Number")

            TextBox(text: $email, placeholder: "Enter your email", lable: "Email")

            PasswordField(password: $password, placeholder: "Create a password", label: "Password")

            PasswordField(password: $confirmPassword, placeholder: "Confirm password", label: "Confirm Password")

            CheckboxView(isChecked: $agreeTerms, label: "I agree to the terms and conditions")

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            PrimaryButton(title: "Register") {
                
                if password != confirmPassword {
                    errorMessage = "Passwords do not match."
                    return
                }
                
                authVM.register(email: email, password: password, username: username, mobile: mobileNumber) { error in
                    if let error = error {
                        self.errorMessage = error
                    }
                }
            }

            Spacer()

            HStack {
                Text("Already have an account?")
                NavigationLink("Log in", destination: LoginView())
            }
            .font(.footnote)
        }
        .padding()
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView()
        }
    }
}
