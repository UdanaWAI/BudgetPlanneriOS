import Foundation
import FirebaseFirestore

class GroupBudgetModel: Identifiable, ObservableObject, Equatable, Hashable {
    @Published var id: String
    @Published var name: String
    @Published var caption: String
    @Published var value: Double
    @Published var type: String
    @Published var date: Date
    @Published var isRecurring: Bool
    @Published var setReminder: Bool
    @Published var isActive: Bool
    @Published var userId: String
    @Published var members: [String]
    @Published var joinCode: String 

    init(
        id: String = UUID().uuidString,
        name: String,
        caption: String,
        value: Double,
        type: String,
        date: Date,
        isRecurring: Bool,
        setReminder: Bool,
        isActive: Bool = false,
        userId: String,
        members: [String] = [],
        joinCode: String = UUID().uuidString.prefix(8).description
    ) {
        self.id = id
        self.name = name
        self.caption = caption
        self.value = value
        self.type = type
        self.date = date
        self.isRecurring = isRecurring
        self.setReminder = setReminder
        self.isActive = isActive
        self.userId = userId
        self.members = members
        self.joinCode = joinCode
    }

    func toDict() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "caption": caption,
            "value": value,
            "type": type,
            "date": Timestamp(date: date),
            "isRecurring": isRecurring,
            "setReminder": setReminder,
            "isActive": isActive,
            "userId": userId,
            "members": members,
            "joinCode": joinCode
        ]
    }

    convenience init(from dict: [String: Any]) {
        let id = dict["id"] as? String ?? UUID().uuidString
        let name = dict["name"] as? String ?? ""
        let caption = dict["caption"] as? String ?? ""
        let value = dict["value"] as? Double ?? 0.0
        let type = dict["type"] as? String ?? ""
        let timestamp = dict["date"] as? Timestamp
        let date = timestamp?.dateValue() ?? Date()
        let isRecurring = dict["isRecurring"] as? Bool ?? false
        let setReminder = dict["setReminder"] as? Bool ?? false
        let isActive = dict["isActive"] as? Bool ?? false
        let userId = dict["userId"] as? String ?? ""
        let members = dict["members"] as? [String] ?? []
        let joinCode = dict["joinCode"] as? String ?? UUID().uuidString.prefix(8).description

        self.init(
            id: id,
            name: name,
            caption: caption,
            value: value,
            type: type,
            date: date,
            isRecurring: isRecurring,
            setReminder: setReminder,
            isActive: isActive,
            userId: userId,
            members: members,
            joinCode: joinCode
        )
    }

    static func == (lhs: GroupBudgetModel, rhs: GroupBudgetModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
