import Foundation
import FirebaseFirestore

class BudgetViewModel: ObservableObject {
    @Published var budgets: [BudgetModel] = []

    private let db = Firestore.firestore()

    // MARK: - Save Budget
    func saveBudget(_ budget: BudgetModel, completion: @escaping (Error?) -> Void) {
        guard !budget.userId.isEmpty else {
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid user"]))
            return
        }

        db.collection("users")
            .document(budget.userId)
            .collection("budgets")
            .document(budget.id)
            .setData(budget.toDict()) { error in
                completion(error)
            }
    }

    // MARK: - Fetch Budgets
    func fetchBudgets(for userId: String) {
        db.collection("users")
            .document(userId)
            .collection("budgets")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching budgets: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                let newBudgets: [BudgetModel] = documents.compactMap { doc in
                    try? BudgetModel(from: doc.data())
                }

                DispatchQueue.main.async {
                    self.budgets = newBudgets
                }
            }
    }

    // MARK: - Set Active Budget
    func setActive(_ selected: BudgetModel) {
        Task {
            do {
                for budget in budgets {
                    let isSelected = budget.id == selected.id
                    try await db.collection("users")
                        .document(budget.userId)
                        .collection("budgets")
                        .document(budget.id)
                        .updateData(["isActive": isSelected])
                }

                DispatchQueue.main.async {
                    self.budgets = self.budgets.map {
                        var mutable = $0
                        mutable.isActive = ($0.id == selected.id)
                        return mutable
                    }
                }

            } catch {
                print("Error setting active budget: \(error)")
            }
        }
    }

    // MARK: - Delete Budget
    func deleteBudget(_ budget: BudgetModel) {
        Task {
            do {
                try await db.collection("users")
                    .document(budget.userId)
                    .collection("budgets")
                    .document(budget.id)
                    .delete()

                DispatchQueue.main.async {
                    self.budgets.removeAll { $0.id == budget.id }
                }
            } catch {
                print("Failed to delete budget: \(error)")
            }
        }
    }
}
