import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                // Check if user is authenticated and display username
                if let user = authVM.user {
                    Text("Welcome, \(user.username) 👋")
                        .font(.title)
                        .fontWeight(.semibold)
                } else {
                    // This will display if the user is not loaded
                    Text("Loading user...")
                        .font(.title)
                        .foregroundColor(.gray)
                }

                // Navigation to Budget List
                NavigationButton(title: "View Budget", foregroundColor: .white, backgroundColor: .blue, destination: BudgetListView())

                // Logout Button
                PrimaryButton(title: "Log Out") {
                    authVM.logout()
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Dashboard", displayMode: .inline)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let authVM = AuthViewModel()
        authVM.user = AppUser(id: "sampleUser", username: "Demo", mobile: "123456", email: "demo@example.com")

        return DashboardView()
            .environmentObject(authVM)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
