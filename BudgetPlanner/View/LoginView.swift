import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var errorMessage = ""
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing:20) {
            Spacer()

           Image("Mar-Business_16 1-3")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            TextBox(text: $email, placeholder: "Enter your email", lable: "Email").autocorrectionDisabled(false).textInputAutocapitalization(.none)

            PasswordField(password: $password, placeholder: "Enter your password", label: "Password")

            HStack{
                CheckboxView(isChecked: $rememberMe, label: "Remember me")
                Spacer()
            }
            

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
            
            Button(action: {
                authVM.biometricLogin { error in
                    if let error = error {
                        print("Biometric login error:", error)
                    }
                }
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "touchid")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.indigo)
                }
                .padding(5)
                .background(Color.white)
                .cornerRadius(50)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
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
