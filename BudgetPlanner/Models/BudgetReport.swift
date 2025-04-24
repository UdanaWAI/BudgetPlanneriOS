import Foundation

struct BudgetReport: Identifiable {
    let id = UUID()
    let budgetName: String
    let budgetType: String
    let totalBudget: Double
    let totalSpent: Double
    let remainingAmount: Double
    let percentUsed: Double
    let expenseCount: Int
}
