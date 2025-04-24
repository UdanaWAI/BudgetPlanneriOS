import SwiftUI

struct BudgetListView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedBudget: BudgetModel?
    @Binding var navigateBackToDashboard: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.indigo)
                    .frame(height: 130)
                    .edgesIgnoringSafeArea(.top)

                CustomAddExpenseButton(title: "Personal Budget List", foregroundColor: .white) {
                    navigateBackToDashboard = false
                }
                .padding(.top, 10)
            }

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
                        ).padding(.top,10)
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
            .padding(.top, -30)

            NavigationLink(destination: CreateBudgetView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create New Budget")
                }
                .padding()
                .foregroundColor(Color.indigo)
                .background(Color.indigo.opacity(0.1))
                .cornerRadius(50)
            }
            .padding()
        }
        .onAppear {
            if let userId = authVM.user?.id {
                viewModel.fetchBudgets(for: userId)
            }
        }.navigationBarBackButtonHidden(true)
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }

    private func setActiveBudget(_ selected: BudgetModel) {
        viewModel.setActive(selected)
    }

    private func deleteBudget(_ budget: BudgetModel) {
        viewModel.deleteBudget(budget)
    }
}



