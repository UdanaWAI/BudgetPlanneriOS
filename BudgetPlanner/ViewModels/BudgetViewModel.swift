import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import CoreData

class BudgetViewModel: ObservableObject {
    @Published var budgets: [BudgetModel] = []

    private let db = Firestore.firestore()
    private let context = PersistenceController.shared.container.viewContext

    // MARK: - Save Budget
    func saveBudget(_ budget: BudgetModel, completion: @escaping (Error?) -> Void) {
        guard !budget.userId.isEmpty else {
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid user"]))
            return
        }

        do {
            // Save to Firebase
            try db.collection("users")
                .document(budget.userId)
                .collection("budgets")
                .document(budget.id)
                .setData(from: budget) { error in
                    if let error = error {
                        completion(error)
                        return
                    }

                    // Save to Core Data
                    self.saveToCoreData(budget)
                    completion(nil)
                }
        } catch {
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

                self.budgets = documents.compactMap { doc in
                    try? doc.data(as: BudgetModel.self)
                }

                // Optionally sync to Core Data
                self.budgets.forEach { self.saveToCoreData($0) }
            }
    }

    // MARK: - Set Active Budget
    func setActive(_ selected: BudgetModel) {
        // Update the local array
        budgets = budgets.map { budget in
            var updated = budget
            updated.isActive = (updated.id == selected.id)
            return updated
        }

        Task {
            do {
                // Set all to inactive
                for budget in budgets where budget.id != selected.id {
                    try await db.collection("users")
                        .document(budget.userId)
                        .collection("budgets")
                        .document(budget.id)
                        .updateData(["isActive": false])
                }

                // Set selected to active
                try await db.collection("users")
                    .document(selected.userId)
                    .collection("budgets")
                    .document(selected.id)
                    .updateData(["isActive": true])

                try saveToCoreData(selected)
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

                try deleteFromCoreData(budget.id)

                DispatchQueue.main.async {
                    self.budgets.removeAll { $0.id == budget.id }
                }
            } catch {
                print("Failed to delete budget: \(error)")
            }
        }
    }

    // MARK: - Core Data Helpers
    private func saveToCoreData(_ model: BudgetModel) {
        let fetchRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", model.id)

        do {
            let results = try context.fetch(fetchRequest)
            let budget = results.first ?? Budget(context: context)

            budget.id = UUID(uuidString: model.id) ?? UUID()
            budget.name = model.name
            budget.caption = model.caption
            budget.value = model.value
            budget.type = model.type
            budget.date = model.date
            budget.isRecurring = model.isRecurring
            budget.setReminder = model.setReminder
            budget.isActive = model.isActive

            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }

    private func deleteFromCoreData(_ id: String) throws {
        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
}
