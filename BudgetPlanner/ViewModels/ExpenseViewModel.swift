import FirebaseFirestore
import SwiftUI

class ExpenseViewModel: ObservableObject {
    @Published var expenses = [ExpenseModel]()
    private var db = Firestore.firestore()

    // Fetch expenses for a specific budget
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

    // Add a new expense
    func addExpense(_ expense: ExpenseModel) {
        db.collection("expenses").addDocument(data: expense.toDict()) { error in
            if let error = error {
                print("Error adding expense: \(error)")
            } else {
                self.fetchExpenses(for: expense.budgetID) // refresh list
            }
        }
    }

    // Delete an expense
    func deleteExpense(_ expense: ExpenseModel) {
        db.collection("expenses").document(expense.id).delete() { error in
            if let error = error {
                print("Error deleting expense: \(error)")
            } else {
                self.fetchExpenses(for: expense.budgetID) // refresh list
            }
        }
    }
}
