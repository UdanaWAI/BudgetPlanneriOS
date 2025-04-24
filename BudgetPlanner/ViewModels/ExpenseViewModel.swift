import FirebaseFirestore
import SwiftUI

class ExpenseViewModel: ObservableObject {
    @Published var expenses = [ExpenseModel]()
    private var db = Firestore.firestore()

    func fetchExpenses(for budgetID: String) {
        db.collection("expenses").whereField("budgetID", isEqualTo: budgetID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching expenses: \(error)")
                return
            }

            self.expenses = querySnapshot?.documents.compactMap { document in
                try? document.data(as: ExpenseModel.self)
            } ?? []
        }
    }

    func addExpense(_ expense: ExpenseModel, for budget: BudgetModel) {
        db.collection("expenses").addDocument(data: expense.toDict()) { error in
            if let error = error {
                print("Error adding expense: \(error)")
            } else {
                self.fetchExpenses(for: expense.budgetID)
                self.updateBudgetValue(by: expense.amount, for: budget)
            }
        }
    }

    private func updateBudgetValue(by spent: Double, for budget: BudgetModel) {
            let newValue = max(0, budget.value - spent)

            db.collection("users")
                .document(budget.userId)
                .collection("budgets")
                .document(budget.id)
                .updateData(["value": newValue]) { error in
                    if error == nil {
                        budget.value = newValue
                    }
                }
        }
    
    func deleteExpense(_ expense: ExpenseModel) {
        db.collection("expenses").document(expense.id).delete() { error in
            if let error = error {
                print("Error deleting expense: \(error)")
            } else {
                self.fetchExpenses(for: expense.budgetID)
            }
        }
    }
}
