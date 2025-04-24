import SwiftUI
import FirebaseFirestore

struct JoinGroupBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var joinCode: String = ""
    @State private var isJoining = false
    @State private var joinMessage: String = ""
    @State private var showAlert = false
    
    var userId: String

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Join a Group Budget")) {
                    TextField("Enter Join Code", text: $joinCode)
                        .textCase(.uppercase)
                        .autocapitalization(.allCharacters)
                }

                Section {
                    Button(action: joinGroupBudget) {
                        if isJoining {
                            ProgressView()
                        } else {
                            Text("Join")
                        }
                    }
                    .disabled(joinCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Join Group Budget")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Join Status"), message: Text(joinMessage), dismissButton: .default(Text("OK")) {
                    if joinMessage.contains("successfully") {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        }
    }

    func joinGroupBudget() {
        isJoining = true
        let db = Firestore.firestore()
        let usersRef = db.collection("users")

        usersRef.getDocuments { (snapshot, error) in
            guard let usersSnapshot = snapshot else {
                joinMessage = "Failed to search for group budgets."
                showAlert = true
                isJoining = false
                return
            }

            var didJoin = false
            let dispatchGroup = DispatchGroup()

            for doc in usersSnapshot.documents {
                dispatchGroup.enter()
                let groupBudgetsRef = usersRef.document(doc.documentID).collection("groupBudgets")
                
                groupBudgetsRef.whereField("joinCode", isEqualTo: joinCode)
                    .getDocuments { (groupSnapshot, error) in
                        if let budgetDoc = groupSnapshot?.documents.first {
                            let budgetID = budgetDoc.documentID
                            let budgetRef = groupBudgetsRef.document(budgetID)

                            budgetRef.updateData([
                                "members": FieldValue.arrayUnion([userId])
                            ]) { err in
                                if let err = err {
                                    joinMessage = "Failed to join group: \(err.localizedDescription)"
                                } else {
                                    joinMessage = "Successfully joined the group budget!"
                                    didJoin = true
                                }
                                showAlert = true
                                isJoining = false
                            }
                        }
                        dispatchGroup.leave()
                    }
            }

            dispatchGroup.notify(queue: .main) {
                if !didJoin {
                    joinMessage = "No group budget found with the provided code."
                    showAlert = true
                    isJoining = false
                }
            }
        }
    }
}
