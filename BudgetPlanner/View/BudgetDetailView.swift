import SwiftUI

struct BudgetDetailView: View {
    let budget: BudgetModel
    @State private var showCreateExpense = false
    @StateObject private var expenseVM = ExpenseViewModel()

    // Computed property to filter expenses related to the current budget
    var filteredExpenses: [ExpenseModel] {
        expenseVM.expenses.filter { $0.budgetID == budget.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Budget Info Section
                VStack(alignment: .leading, spacing: 10) {
                    Text(budget.name)
                        .font(.title)
                        .bold()

                    Text("Current Balance")
                        .font(.caption)

                    Text("$\(budget.value, specifier: "%.2f")")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.purple)

                    Text(formattedMonth(budget.date))
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Divider()

                    Text("Caption: \(budget.caption)")
                        .font(.body)

                    Text("Budget Type: \(budget.type)")
                        .font(.body)

                    Divider()

                    CheckboxView(isChecked: .constant(budget.isRecurring), label: "Set Recurring")
                    CheckboxView(isChecked: .constant(budget.setReminder), label: "Set Reminder")

                    Button(action: {
                        showCreateExpense = true
                    }) {
                        Label("Add Expense", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top)
                    }
                }
                .padding(.horizontal)

                // MARK: - Expense Cards Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Expenses")
                        .font(.headline)
                        .padding(.horizontal)

                    if filteredExpenses.isEmpty {
                        Text("No expenses yet.")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(filteredExpenses) { expense in
                            ExpenseCardView(expense: expense, budgetValue: budget.value)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Personal Budget")
        .onAppear {
            expenseVM.fetchExpenses(for: budget.id)
        }
        .sheet(isPresented: $showCreateExpense) {
            CreateExpenseView(budget: budget) {
                expenseVM.fetchExpenses(for: budget.id)
            }
        }
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}
