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

    // Variable to hold the active budget
    @State private var activeBudget: BudgetModel?

    var body: some View {
        VStack() {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.indigo)
                    .frame(height: 130)
                    .edgesIgnoringSafeArea(.top)
                    .padding(.top,-22)
                // welcome and log out
                HStack {
                    if let user = authVM.user {
                        Text("Welcome, \(user.username)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        authVM.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.trailing, 4)
                    }
                    .accessibilityLabel("Log Out")
                }
                .padding(.top,15).padding(.horizontal,20)
            }

            // Fetch active budget and display BudgetView
            if let activeBudget = activeBudget {
                BudgetView(
                    title: activeBudget.name,
                    currentBalance: activeBudget.value,
                    expenses: activeBudget.value * 0.6,
                    monthlyBudget: activeBudget.value,
                    monthYear: formatMonthYear(from: activeBudget.date)
                )
                .padding(.top)
            } else {
                Text("No active budget selected")
                    .foregroundColor(.indigo)
                    .font(.title3)
                    .padding(.top, 10)
            }
            Spacer()
            // Dashboard buttons
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                DashboardIconButton(title: "Personal Budget", icon: "hands.sparkles.fill", color: .yellow) {
                    navigateToBudgetList = true
                }
                
                DashboardIconButton(title: "Group Budget", icon: "banknote.fill", color: .green) {
                    navigateToGroupBudgetList = true
                }
                DashboardIconButton(title: "Expenses", icon: "doc.text.fill", color: .orange) {
                    navigateToAddExpenses = true
                }
                DashboardIconButton(title: "Monthly Reports", icon: "chart.bar.fill", color: .purple) {
                    navigateToReports = true
                }
            }.padding(.bottom)

            Spacer()

            // Tab bar
            SimpleTabBar { selectedTab in
                switch selectedTab {
                case .personal:
                    navigateToBudgetList = true
                case .dashboard:
                    break
                case .expenses:
                    navigateToAddExpenses = true
                case .reports:
                    navigateToReports = true
                case .group:
                    navigateToGroupBudgetList = true
                }
            }

            // Navigation links links
            NavigationLink(destination: BudgetListView(navigateBackToDashboard: $navigateToBudgetList), isActive: $navigateToBudgetList) { EmptyView() }
            NavigationLink(destination: AddExpensesView(budgetViewModel: budgetViewModel), isActive: $navigateToAddExpenses) { EmptyView() }
            NavigationLink(destination: ReportView(userId: authVM.user?.id ?? "", navigateBackToDashboard: $navigateToReports), isActive: $navigateToReports) { EmptyView() }
            NavigationLink(destination: GroupBudgetListView(viewModel: GroupBudgetViewModel(userId: authVM.user?.id ?? ""), navigateBackToDashboard: $navigateToGroupBudgetList), isActive: $navigateToGroupBudgetList) { EmptyView() }
            NavigationLink(destination: JoinGroupBudgetView(userId: authVM.user?.id ?? ""), isActive: $navigateToJoinGroup) { EmptyView() }

        }
        .refreshable {
            refreshDashboard()}
        .onAppear {
            // Fetch the active budget when the view appears
            if let userId = authVM.user?.id {
                budgetViewModel.fetchBudgets(for: userId)
            }
        }
        .onChange(of: budgetViewModel.budgets) { _ in
            // Set the active budget when budgets are fetched
            if let active = budgetViewModel.budgets.first(where: { $0.isActive }) {
                activeBudget = active
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func refreshDashboard() {
            if let userId = authVM.user?.id {
                budgetViewModel.fetchBudgets(for: userId)
            }
        }

    private func formatMonthYear(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
