import Foundation

struct Expense: Identifiable {
    let id = UUID()
    let title: String
    let amountSpent: Double
    let totalBudget: Double
    
    var remaining: Double {
        totalBudget - amountSpent
    }
    
    var progress: Double {
        amountSpent / totalBudget
    }
}
