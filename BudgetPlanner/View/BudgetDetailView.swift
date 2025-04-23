import SwiftUI

struct BudgetDetailView: View {
    let budget: BudgetModel
    @State private var showCreateExpense = false
    @StateObject private var expenseVM = ExpenseViewModel()
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

                CustomBackButton(title: "Personal Budget")

                BudgetView(
                    title: budget.name,
                    currentBalance: budget.value - totalExpenses,
                    expenses: totalExpenses,
                    monthlyBudget: budget.value,
                    monthYear: formattedMonth(budget.date)
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Caption: \(budget.caption)")
                        .font(.body)

                    Text("Budget Type: \(budget.type)")
                        .font(.body)

                    Divider()

                    HStack{
                        CheckboxView(isChecked: .constant(budget.isRecurring), label: "Set Recurring")
                        Spacer()
                        CheckboxView(isChecked: .constant(budget.setReminder), label: "Set Reminder")
                    }
                    Button(action: {
                        showCreateExpense = true
                    }) {
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
        .navigationBarBackButtonHidden(true) // Hide system back button
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


struct BudgetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock BudgetModel data
        let mockBudget = BudgetModel(
            id: "1",
            name: "Personal Budget",
            caption: "Monthly expenses for personal use",
            value: 1500.00,
            type: "Personal",
            date: Date(),
            isRecurring: true,
            setReminder: true,
            userId: "user123"
        )

        // Mock expenses that belong to this budget
        let mockExpenses = [
            ExpenseModel(id: "1", name: "Groceries", amount: 200, date: Date(), budgetID: mockBudget.id),
            ExpenseModel(id: "2", name: "Dining Out", amount: 50, date: Date(), budgetID: mockBudget.id)
        ]
        
        // Create the ExpenseViewModel with mock data
        let expenseVM = ExpenseViewModel()
        expenseVM.expenses = mockExpenses

        return BudgetDetailView(budget: mockBudget)
            .environmentObject(expenseVM) // Pass ExpenseViewModel as an environment object
            .previewDevice("iPhone 12") // Adjust to desired preview device
    }
}
