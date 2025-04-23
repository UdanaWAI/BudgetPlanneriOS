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

struct BudgetListView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock AppUser
        let mockUser = AppUser(id: "user123", username: "Jane Doe", mobile: "1234567890", email: "jane@example.com")
        
        // Mock AuthViewModel with AppUser
        let mockAuthVM = AuthViewModel()
        mockAuthVM.user = mockUser
        
        // Mock budgets data
        let mockBudgets = [
            BudgetModel(id: "1", name: "Groceries", caption: "Monthly food budget", value: 500.0, type: "Food", date: Date(), isRecurring: true, setReminder: true, isActive: true, userId: mockUser.id ?? ""),
            BudgetModel(id: "2", name: "Entertainment", caption: "For movies and outings", value: 200.0, type: "Leisure", date: Date(), isRecurring: false, setReminder: false, isActive: false, userId: mockUser.id ?? "")
        ]

        // Mock BudgetViewModel
        let mockBudgetVM = BudgetViewModel()
        mockBudgetVM.budgets = mockBudgets

        return BudgetListView()
            .environmentObject(mockAuthVM)
            .environmentObject(mockBudgetVM)
            .previewDevice("iPhone 14")
    }
}

