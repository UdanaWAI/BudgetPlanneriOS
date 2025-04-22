import SwiftUI

struct BudgetListView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedBudget: BudgetModel?

    var body: some View {
        NavigationView {
            VStack {
                Text("Personal Budget List")
                    .font(.title2)
                    .padding(.top)

                ScrollView {
                    ForEach(viewModel.budgets) { budget in
                        NavigationLink(
                            destination: BudgetDetailView(budget: budget),
                            tag: budget,
                            selection: $selectedBudget
                        ) {
                            BudgetCardView(
                                name: budget.name,
                                month: formattedMonth(budget.date),
                                isActive: budget.isActive
                            )
                            .contextMenu {
                                Button(action: {
                                    setActiveBudget(budget)
                                }) {
                                    Label("Set Active", systemImage: "checkmark.circle.fill")
                                }

                                Button(role: .destructive) {
                                    deleteBudget(budget)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                NavigationLink(destination: CreateBudgetView()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Budget")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .padding(.horizontal)
            .onAppear {
                if let userId = authVM.user?.id {
                    viewModel.fetchBudgets(for: userId)
                }
            }
        }
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }

    // MARK: - Set Budget as Active
    private func setActiveBudget(_ selected: BudgetModel) {
        viewModel.setActive(selected)
    }

    // MARK: - Delete Budget
    private func deleteBudget(_ budget: BudgetModel) {
        viewModel.deleteBudget(budget)
    }
}
