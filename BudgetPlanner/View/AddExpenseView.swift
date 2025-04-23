import SwiftUI
import FirebaseFirestore

struct CreateExpenseView: View {
    @Environment(\.presentationMode) var presentationMode

    let budget: BudgetModel
    var onExpenseAdded: (() -> Void)? = nil

    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $name)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(action: addExpense) {
                    Text("Add Expense")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationBarTitle("New Expense", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    func addExpense() {
        guard !name.isEmpty else {
            errorMessage = "Please enter a title."
            return
        }

        guard let amountDouble = Double(amount), amountDouble > 0 else {
            errorMessage = "Enter a valid amount."
            return
        }

        let db = Firestore.firestore()
        let expense = ExpenseModel(
            id: UUID().uuidString,
            name: name,
            amount: amountDouble,
            date: date,
            budgetID: budget.id
        )

        db.collection("expenses").document(expense.id).setData(expense.toDict()) { error in
            if let error = error {
                self.errorMessage = "Failed to save expense: \(error.localizedDescription)"
            } else {
                updateBudgetValue(by: amountDouble)
                onExpenseAdded?()
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }

    func updateBudgetValue(by spent: Double) {
        let db = Firestore.firestore()
        let newValue = max(0, budget.value - spent)
        db.collection("users")
            .document(budget.userId)
            .collection("budgets")
            .document(budget.id)
            .updateData(["value": newValue]) { error in
                if error == nil {
                    // You can optionally notify UI or update local budget state
                }
            }
    }
}
