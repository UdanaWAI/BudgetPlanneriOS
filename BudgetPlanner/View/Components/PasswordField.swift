import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    var placeholder: String
    var label: String

    @State private var isSecure: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $password)
                    } else {
                        TextField(placeholder, text: $password)
                    }
                }

                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.4))
            )
            .font(.system(size: 16))
        }
    }
}

struct PasswordField_Previews: PreviewProvider {
    static var previews: some View {
        PasswordField(password: .constant(""), placeholder: "Enter password", label: "Password")
            .padding()
    }
}
