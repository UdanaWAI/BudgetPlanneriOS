import Foundation

// This assumes you're using a struct for BudgetModel
struct BudgetModel: Identifiable, Codable {
    var id: String
    var userId: String
    var name: String
    var caption: String
    var value: Double
    var type: String
    var date: Date
    var isRecurring: Bool
    var setReminder: Bool
    var isActive: Bool // Added 'isActive' property
}
