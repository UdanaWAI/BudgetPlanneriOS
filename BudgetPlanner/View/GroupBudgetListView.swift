import SwiftUI

struct GroupBudgetListView: View {
    @StateObject var viewModel: GroupBudgetViewModel
    @State private var showAddBudgetView = false
    @State private var selectedBudget: GroupBudgetModel? = nil
    @Binding var navigateBackToDashboard: Bool

    @State private var navigateToBudgetList = false
    @State private var navigateToReports = false
    @State private var navigateToExpenses = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.indigo)
                    .frame(height: 130)
                    .edgesIgnoringSafeArea(.top)

                CustomCancelButton(title: "Group Budget List", foregroundColor: .white) {
                    navigateBackToDashboard = false
                }
                .padding(.top, 10)
            }

            ScrollView {
                ForEach(viewModel.groupBudgets) { budget in
                    NavigationLink(
                        destination: GroupBudgetDetailView(budget: budget),
                        tag: budget,
                        selection: $selectedBudget
                    ) {
                        BudgetCardView(
                            name: budget.name,
                            month: formattedMonth(budget.date)
                        )
                        .padding(.top, 10)
                        .contextMenu {
                            Button(action: {
                                // Future logic for setting active
                            }) {
                                Label("Set Active", systemImage: "checkmark.circle.fill")
                            }

                            Button(role: .destructive) {
                                // Future logic for deletion
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, -30)

            NavigationLink(destination: CreateGroupBudgetView(viewModel: viewModel)) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create New Group Budget")
                }
                .padding()
                .foregroundColor(Color.indigo)
                .background(Color.indigo.opacity(0.1))
                .cornerRadius(50)
            }
            .padding()

            // MARK: - Tab Bar
            SimpleTabBar { selectedTab in
                switch selectedTab {
                case .dashboard:
                    navigateBackToDashboard = false
                case .personal:
                        navigateToBudgetList = true
                case .expenses:
                    navigateToExpenses = true
                case .reports:
                    navigateToReports = true
                case .group:
                    break // already here
                }
            }
            .padding(.bottom, 4)
        }
        .background(
            Group {
                NavigationLink(destination: AddExpensesView(budgetViewModel: BudgetViewModel()), isActive: $navigateToExpenses) {
                    EmptyView()
                }
                NavigationLink(destination: BudgetListView(navigateBackToDashboard: $navigateToBudgetList), isActive: $navigateToBudgetList) {
                    EmptyView()
                }
                NavigationLink(destination: ReportView(userId: viewModel.userId, navigateBackToDashboard: $navigateBackToDashboard), isActive: $navigateToReports) {
                    EmptyView()
                }
            }
        )
        .onAppear {
            viewModel.fetchGroupBudgets()
        }
        .navigationBarBackButtonHidden(true)
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }
}
