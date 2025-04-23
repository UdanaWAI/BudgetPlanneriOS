import SwiftUI

struct BudgetDetailView: View {
    let budget: BudgetModel
    @StateObject private var expenseVM = ExpenseViewModel()
    @StateObject private var budgetVM = BudgetViewModel()
    @Environment(\.presentationMode) var presentationMode

    var filteredExpenses: [ExpenseModel] {
        expenseVM.expenses.filter { $0.budgetID == budget.id }
    }

    var totalExpenses: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {

                
                CustomBackButton(title: "Personal Budget", foregroundColor: .indigo)

                BudgetView(
                    title: budget.name,
                    currentBalance: budget.value - totalExpenses,
                    expenses: totalExpenses,
                    monthlyBudget: budget.value,
                    monthYear: formattedMonth(budget.date)
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Caption: \(budget.caption)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.gray)

                    Text("Budget Type: \(budget.type)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)

                    Divider()

                    HStack {
                        CheckboxView(isChecked: .constant(budget.isRecurring), label: "Set Recurring")
                        Spacer()
                        CheckboxView(isChecked: .constant(budget.setReminder), label: "Set Reminder")
                    }

                    NavigationLink(destination: AddExpensesView(
                        budgetViewModel: budgetVM,
                        preselectedBudget: budget,
                        onExpenseAdded: {
                            expenseVM.fetchExpenses(for: budget.id)
                        }
                    )) {
                        Label("Add Expense", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        Text("Expenses")
                            .font(.headline)
                            .padding(.horizontal)
                            .foregroundColor(.indigo)
                        Spacer()
                    }

                    Divider()

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
        .navigationBarBackButtonHidden(true)
        .onAppear {
            expenseVM.fetchExpenses(for: budget.id)
            budgetVM.fetchBudgets(for: budget.userId)
        }.navigationBarBackButtonHidden(true)
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}
