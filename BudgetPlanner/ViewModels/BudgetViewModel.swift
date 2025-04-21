import Foundation
import FirebaseFirestore
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

        db.collection("users")
            .document(budget.userId)
            .collection("budgets")
            .document(budget.id)
            .setData(budget.toDict()) { error in
                if let error = error {
                    completion(error)
                    return
                }

                self.saveToCoreData(budget)
                completion(nil)
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
                    newBudgets.forEach { self.saveToCoreData($0) }
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

                    var updated = budget
                    updated.isActive = isSelected
                    saveToCoreData(updated)
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
        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", model.id)

        do {
            let result = try context.fetch(request).first ?? Budget(context: context)

            result.id = UUID(uuidString: model.id) ?? UUID()
            result.name = model.name
            result.caption = model.caption
            result.value = model.value
            result.type = model.type
            result.date = model.date
            result.isRecurring = model.isRecurring
            result.setReminder = model.setReminder
            result.isActive = model.isActive

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
