import SwiftUI

struct BudgetDetailView: View {
    let budget: BudgetModel
    @State private var showCreateExpense = false

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
                    .disabled(true) // Disable until expense support is added
                }
                .padding(.horizontal)

                // MARK: - Expense Cards Section (not yet implemented)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Expenses")
                        .font(.headline)
                        .padding(.horizontal)

                    Text("Expenses will appear here once added.")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

            }
            .padding(.top)
        }
        .navigationTitle("Personal Budget")
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}

