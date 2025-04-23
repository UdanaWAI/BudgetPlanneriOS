import Foundation
import FirebaseFirestore

class ExpenseModel: Identifiable, ObservableObject, Hashable, Decodable {
    @Published var id: String
    @Published var name: String
    @Published var amount: Double
    @Published var date: Date
    @Published var budgetID: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amount
        case date
        case budgetID = "budgetID" // Match Firestore field names
    }

    // MARK: - Initializer
    init(id: String = UUID().uuidString, name: String, amount: Double, date: Date, budgetID: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
        self.budgetID = budgetID
    }

    // MARK: - Firebase Conversion
    func toDict() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "amount": amount,
            "date": Timestamp(date: date),
            "budgetID": budgetID
        ]
    }

    // MARK: - Firebase Init (from Firebase Data)
    convenience init(from dict: [String: Any]) {
        let id = dict["id"] as? String ?? UUID().uuidString
        let name = dict["name"] as? String ?? ""
        let amount = dict["amount"] as? Double ?? 0.0
        let timestamp = dict["date"] as? Timestamp
        let date = timestamp?.dateValue() ?? Date()
        let budgetID = dict["budgetID"] as? String ?? ""

        self.init(id: id, name: name, amount: amount, date: date, budgetID: budgetID)
    }

    // MARK: - Hashable
    static func == (lhs: ExpenseModel, rhs: ExpenseModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.date = try container.decode(Date.self, forKey: .date)
        self.budgetID = try container.decode(String.self, forKey: .budgetID)
    }
}
