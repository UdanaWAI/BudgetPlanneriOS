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
    
    // MARK: - Fetch Group Budgets
    func fetchGroupBudgets() {
        db.collection("users").document(userId).collection("groupBudgets")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching group budgets: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self.groupBudgets = documents.map { doc -> GroupBudgetModel in
                    let data = doc.data()
                    return GroupBudgetModel(from: data)
                }
            }
    }
    
    // MARK: - Add a Group Budget
    func addGroupBudget(_ budget: GroupBudgetModel) {
        var newBudget = budget
        let docRef = db.collection("users").document(userId).collection("groupBudgets").document()
        newBudget.id = docRef.documentID  // Assign the Firestore document ID to the model
        
        docRef.setData(newBudget.toDict()) { error in
            if let error = error {
                print("Error adding group budget: \(error.localizedDescription)")
            } else {
                print("Group budget added successfully!")
            }
        }
    }
    
    // MARK: - Update a Group Budget
    func updateGroupBudget(_ budget: GroupBudgetModel) {
        let docRef = db.collection("users").document(userId).collection("groupBudgets").document(budget.id)
        
        docRef.updateData(budget.toDict()) { error in
            if let error = error {
                print("Error updating group budget: \(error.localizedDescription)")
            } else {
                print("Group budget updated successfully!")
            }
        }
    }
    
    // MARK: - Delete a Group Budget
    func deleteGroupBudget(_ budget: GroupBudgetModel) {
        let docRef = db.collection("users").document(userId).collection("groupBudgets").document(budget.id)
        
        docRef.delete() { error in
            if let error = error {
                print("Error deleting group budget: \(error.localizedDescription)")
            } else {
                print("Group budget deleted successfully!")
            }
        }
    }
}
