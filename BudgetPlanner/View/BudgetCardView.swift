import SwiftUI
import CoreData

struct BudgetListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = BudgetViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Budget.date, ascending: false)]
    ) private var budgets: FetchedResults<Budget>

    var body: some View {
        NavigationView {
            VStack {
                Text("Personal Budget List")
                    .font(.title2)
                    .padding(.top)

                ScrollView {
                    ForEach(budgets, id: \.id) { budget in
                        NavigationLink(destination: BudgetDetailView(budget: budget)) {
                            BudgetCardView(
                                name: budget.name ?? "Unnamed",
                                month: formattedMonth(budget.date),
                                isActive: budget.isActive
                            )
                            .contextMenu {
                                Button(action: {
                                    setActiveBudget(budget)
                                }) {
                                    Label("Set Active", systemImage: "checkmark.circle.fill")
                                }

                                Button(role: .destructive) {
                                    deleteBudget(budget)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                NavigationLink(destination: CreateBudgetView()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Budget")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .padding(.horizontal)
            .onAppear {
                if let userId = authVM.user?.id {
                    viewModel.fetchBudgets(for: userId)
                }
            }
        }
    }

    func formattedMonth(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }

    // MARK: - Set Budget as Active
    private func setActiveBudget(_ selected: Budget) {
        // 1. Update Core Data to reflect the active state
        for budget in budgets {
            budget.isActive = (budget.id == selected.id)
        }

        do {
            try viewContext.save()
        } catch {
            print("Error saving active budget: \(error.localizedDescription)")
        }

        // 2. Push change to Firebase
        let model = BudgetModel(
            id: selected.firebaseID ?? UUID().uuidString,
            name: selected.name ?? "",
            caption: selected.caption ?? "",
            value: selected.value,
            type: selected.type ?? "",
            date: selected.date ?? Date(),
            isRecurring: selected.isRecurring,
            setReminder: selected.setReminder,
            isActive: true,
            userId: selected.userId ?? ""
        )

        viewModel.setActive(model)
    }

    // MARK: - Delete Budget
    private func deleteBudget(_ budget: Budget) {
        guard let firebaseID = budget.firebaseID,
              let userId = budget.userId else {
            print("Missing Firebase ID or user ID")
            return
        }

        // 1. Delete from Firebase
        let model = BudgetModel(
            id: firebaseID,
            name: budget.name ?? "",
            caption: budget.caption ?? "",
            value: budget.value,
            type: budget.type ?? "",
            date: budget.date ?? Date(),
            isRecurring: budget.isRecurring,
            setReminder: budget.setReminder,
            isActive: budget.isActive,
            userId: userId
        )

        viewModel.deleteBudget(model)

        // 2. Delete from Core Data
        viewContext.delete(budget)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting budget locally: \(error.localizedDescription)")
        }
    }
}

struct BudgetListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let authVM = AuthViewModel()
        authVM.user = AppUser(id: "preview-user", username: "Tester", mobile: "0000", email: "tester@example.com")

        return BudgetListView()
            .environment(\.managedObjectContext, context)
            .environmentObject(authVM)
    }
}
