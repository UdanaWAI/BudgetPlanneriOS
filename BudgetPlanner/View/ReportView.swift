import SwiftUI

struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ReportViewModel()
    let userId: String
    @Binding var navigateBackToDashboard: Bool

    @State private var navigateToExpenses = false
    @State private var navigateToBudgetList = false
    @State private var navigateToGroupBudgetList = false
    

    var body: some View {
        VStack(spacing: 16) {
            CustomCancelButton(title: "Budget Reports", foregroundColor: .indigo) {
                navigateBackToDashboard = false
            }
            .padding(.top, 10)

            BudgetChartView(userId: userId)
                .padding(.top, 30)
                .padding(.vertical, 10)

            List(viewModel.reportData) { report in
                VStack(alignment: .leading, spacing: 6) {
                    Text(report.budgetName)
                        .font(.headline)
                    ProgressView(value: report.percentUsed, total: 100)
                        .accentColor(report.percentUsed > 100 ? .red : .green)
                    HStack {
                        Text("Spent: \(report.totalSpent, specifier: "%.2f")")
                        Spacer()
                        Text("Remaining: \(report.remainingAmount, specifier: "%.2f")")
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 6)
            }
            .navigationBarBackButtonHidden(true)

            Spacer()

            // Tab Bar
            SimpleTabBar { selectedTab in
                switch selectedTab {
                case .dashboard:
                    presentationMode.wrappedValue.dismiss()
                case .personal:
                        navigateToBudgetList = true
                case .expenses:
                    navigateToExpenses = true
                case .reports:
                    break
                case .group:
                    navigateToGroupBudgetList = true
                }
            }

        }
        .onAppear {
            viewModel.fetchReport(for: userId)
        }

        // Navigation Links
        NavigationLink(destination: AddExpensesView(budgetViewModel: BudgetViewModel()), isActive: $navigateToExpenses) { EmptyView() }
        NavigationLink(destination: BudgetListView(navigateBackToDashboard: $navigateToBudgetList), isActive: $navigateToBudgetList) {
            EmptyView()
        }
        NavigationLink(destination: GroupBudgetListView(viewModel: GroupBudgetViewModel(userId: userId), navigateBackToDashboard: $navigateToGroupBudgetList), isActive: $navigateToGroupBudgetList) { EmptyView() }
    }
}
