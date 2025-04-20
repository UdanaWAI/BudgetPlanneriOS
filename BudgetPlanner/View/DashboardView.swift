import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if let user = authVM.user {
                Text("Welcome, \(user.username) 👋")
                    .font(.title)
                    .fontWeight(.semibold)
            } else {
                Text("Loading user...")
            }

            PrimaryButton(title: "Log Out") {
                authVM.logout()
            }

            Spacer()
        }
        .padding()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthViewModel())
    }
}
