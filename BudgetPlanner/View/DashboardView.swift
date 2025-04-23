import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var budgetViewModel = BudgetViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                if let user = authVM.user {
                    Text("Welcome, \(user.username) 👋")
                        .font(.title)
                        .fontWeight(.semibold)
                } else {
                    Text("Loading user...")
                        .font(.title)
                        .foregroundColor(.gray)
                }

                NavigationLink(
                    destination: BudgetListView()
                        .onAppear {
                            if let userId = authVM.user?.id {
                                budgetViewModel.fetchBudgets(for: userId)
                            }
                        }
                ) {
                    Text("View Budget")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(
                    destination: AddExpensesView(budgetViewModel: budgetViewModel)
                ) {
                    Text("Add Expenses")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                PrimaryButton(title: "Log Out") {
                    authVM.logout()
                }

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}
