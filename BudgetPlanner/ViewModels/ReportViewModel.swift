import Foundation
import Combine
import FirebaseFirestore

class ReportViewModel: ObservableObject {
    @Published var budgets: [BudgetModel] = []
    @Published var expenses: [ExpenseModel] = []
    @Published var reportData: [BudgetReport] = []

    private var cancellables = Set<AnyCancellable>()

    func fetchReport(for userId: String) {
        let db = Firestore.firestore()

        // Fetch Budgets
        db.collection("users").document(userId).collection("budgets").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            let budgets = documents.map { BudgetModel(from: $0.data()) }
            DispatchQueue.main.async {
                self.budgets = budgets
                self.fetchExpenses()
            }
        }
    }

    private func fetchExpenses() {
        let db = Firestore.firestore()

        db.collection("expenses").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            let expenses = documents.map { ExpenseModel(from: $0.data()) }
            DispatchQueue.main.async {
                self.expenses = expenses
                self.generateReport()
            }
        }
    }

    private func generateReport() {
        var report: [BudgetReport] = []

        for budget in budgets {
            let relatedExpenses = expenses.filter { $0.budgetID == budget.id }
            let totalSpent = relatedExpenses.reduce(0) { $0 + $1.amount }
            let remaining = budget.value - totalSpent
            let percentUsed = budget.value > 0 ? (totalSpent / budget.value) * 100 : 0

            let entry = BudgetReport(
                budgetName: budget.name,
                budgetType: budget.type,
                totalBudget: budget.value,
                totalSpent: totalSpent,
                remainingAmount: remaining,
                percentUsed: percentUsed,
                expenseCount: relatedExpenses.count
            )

            report.append(entry)
        }

        self.reportData = report
    }
}
