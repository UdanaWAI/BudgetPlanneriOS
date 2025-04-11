import SwiftUI

struct BudgetDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var budget: Budget
    @State private var showCreateExpense = false

    @FetchRequest private var expenses: FetchedResults<Expense>

    init(budget: Budget) {
        self.budget = budget
        _expenses = FetchRequest<Expense>(
            entity: Expense.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)],
            predicate: NSPredicate(format: "budget == %@", budget)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Budget Info Section
                VStack(alignment: .leading, spacing: 10) {
                    Text(budget.name ?? "No Name")
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
                    
                    Text("Caption: \(budget.caption ?? "-")")
                        .font(.body)
                    Text("Budget Type: \(budget.type ?? "-")")
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

                    if expenses.isEmpty {
                        Text("No expenses recorded yet.")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(expenses) { expense in
                                ExpenseCardView(expense: expense, budgetValue: budget.value)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .padding(.top)
        }
        .sheet(isPresented: $showCreateExpense) {
            CreateExpenseView(selectedBudget: budget)
                .environment(\.managedObjectContext, viewContext)
        }
        .navigationTitle("Personal Budget")
    }

    func formattedMonth(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}

struct BudgetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let sample = Budget(context: context)
        sample.id = UUID()
        sample.name = "Sample Budget"
        sample.caption = "A preview budget"
        sample.value = 300.0
        sample.type = "Monthly"
        sample.date = Date()

        return BudgetDetailView(budget: sample)
            .environment(\.managedObjectContext, context)
    }
}
