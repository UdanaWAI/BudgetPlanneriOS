import Foundation
import FirebaseFirestore
import Combine

class GroupBudgetViewModel: ObservableObject {
    @Published var groupBudgets: [GroupBudgetModel] = []
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    var userId: String

    init(userId: String) {
        self.userId = userId
        fetchGroupBudgets()
    }

    // MARK: - Fetch Group Budgets Owned or Joined by User
    func fetchGroupBudgets() {
        db.collectionGroup("groupBudgets")
            .whereField("members", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching group budgets: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self.groupBudgets = documents.map { GroupBudgetModel(from: $0.data()) }
            }
    }

    // MARK: - Add a New Group Budget
    func addGroupBudget(_ budget: GroupBudgetModel) {
        var newBudget = budget
        let docRef = db.collection("users").document(userId).collection("groupBudgets").document()
        newBudget.id = docRef.documentID
        newBudget.members = [userId] // Add creator as first member

        docRef.setData(newBudget.toDict()) { error in
            if let error = error {
                print("Error adding group budget: \(error.localizedDescription)")
            } else {
                print("Group budget added successfully!")
            }
        }
    }

    // MARK: - Update Group Budget
    func updateGroupBudget(_ budget: GroupBudgetModel) {
        let docRef = db.collection("users").document(budget.userId).collection("groupBudgets").document(budget.id)

        docRef.updateData(budget.toDict()) { error in
            if let error = error {
                print("Error updating group budget: \(error.localizedDescription)")
            } else {
                print("Group budget updated successfully!")
            }
        }
    }

    // MARK: - Delete Group Budget
    func deleteGroupBudget(_ budget: GroupBudgetModel) {
        let docRef = db.collection("users").document(budget.userId).collection("groupBudgets").document(budget.id)

        docRef.delete() { error in
            if let error = error {
                print("Error deleting group budget: \(error.localizedDescription)")
            } else {
                print("Group budget deleted successfully!")
            }
        }
    }

    // MARK: - Join a Group Budget via Join Code
    func joinGroupBudget(withJoinCode code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collectionGroup("groupBudgets")
            .whereField("joinCode", isEqualTo: code)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "GroupBudget", code: 404, userInfo: [NSLocalizedDescriptionKey: "No group found for this code."])))
                    return
                }

                var groupData = document.data()
                var members = groupData["members"] as? [String] ?? []

                if !members.contains(self.userId) {
                    members.append(self.userId)
                    groupData["members"] = members

                    document.reference.updateData(["members": members]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            print("User joined the group successfully.")
                            completion(.success(()))
                        }
                    }
                } else {
                    print("User already in the group.")
                    completion(.success(()))
                }
            }
    }
}
