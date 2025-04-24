import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var budgetViewModel = BudgetViewModel()

    @State private var navigateToBudgetList = false
    @State private var navigateToReportt = false
    @State private var navigateToAddExpenses = false
    @State private var navigateToReports = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                if let user = authVM.user {
                    Text("Welcome, \(user.username) 👋")
                        .font(.title)
                        .fontWeight(.semibold)
                }

                NavigationLink(destination: BudgetListView(navigateBackToDashboard: $navigateToBudgetList), isActive: $navigateToBudgetList) {
                    EmptyView()
                }

                NavigationLink(destination: AddExpensesView(budgetViewModel: budgetViewModel), isActive: $navigateToAddExpenses) {
                    EmptyView()
                }

                NavigationLink(destination: ReportView(userId: authVM.user?.id ?? "", navigateBackToDashboard: $navigateToReports), isActive: $navigateToReports) {
                    EmptyView()
                }

                Button("View Budget") {
                    navigateToBudgetList = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Add Expenses") {
                    navigateToAddExpenses = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                PrimaryButton(title: "Log Out") {
                    authVM.logout()
                }

                Button("View Reports") {
                    navigateToReports = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}
