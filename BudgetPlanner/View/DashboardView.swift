import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var budgetViewModel = BudgetViewModel()

    @State private var navigateToBudgetList = false
    @State private var navigateToAddExpenses = false
    @State private var navigateToReports = false
    @State private var navigateToGroupBudgetList = false
    @State private var navigateToJoinGroup = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                if let user = authVM.user {
                    Text("Welcome, \(user.username) 👋")
                        .font(.title)
                        .fontWeight(.semibold)
                }

                // MARK: - Navigation Links (Hidden)
                NavigationLink(destination: BudgetListView(navigateBackToDashboard: $navigateToBudgetList), isActive: $navigateToBudgetList) { EmptyView() }
                NavigationLink(destination: AddExpensesView(budgetViewModel: budgetViewModel), isActive: $navigateToAddExpenses) { EmptyView() }
                NavigationLink(destination: ReportView(userId: authVM.user?.id ?? "", navigateBackToDashboard: $navigateToReports), isActive: $navigateToReports) { EmptyView() }
                NavigationLink(destination: GroupBudgetListView(viewModel: GroupBudgetViewModel(userId: authVM.user?.id ?? "")), isActive: $navigateToGroupBudgetList) { EmptyView() }
                NavigationLink(destination: JoinGroupBudgetView(userId: authVM.user?.id ?? ""), isActive: $navigateToJoinGroup) { EmptyView() }

                // MARK: - Main Actions
                Group {
                    Button("View Budget") {
                        navigateToBudgetList = true
                    }
                    .buttonStyle(DashboardButtonStyle(color: .blue))

                    Button("Add Expenses") {
                        navigateToAddExpenses = true
                    }
                    .buttonStyle(DashboardButtonStyle(color: .green))

                    Button("View Reports") {
                        navigateToReports = true
                    }
                    .buttonStyle(DashboardButtonStyle(color: .purple))
                }

                Divider().padding(.top)

                // MARK: - Group Budget Section
                Group {
                    Button("View Group Budgets") {
                        navigateToGroupBudgetList = true
                    }
                    .buttonStyle(DashboardButtonStyle(color: .orange))

                    Button("Join Group Budget") {
                        navigateToJoinGroup = true
                    }
                    .buttonStyle(DashboardButtonStyle(color: .teal))
                }

                Spacer()

                // MARK: - Logout
                PrimaryButton(title: "Log Out") {
                    authVM.logout()
                }
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - Reusable Button Style
struct DashboardButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
