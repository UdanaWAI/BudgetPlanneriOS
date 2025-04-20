import SwiftUI
import CoreData

struct BudgetListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = BudgetViewModel()

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
                    ForEach(viewModel.budgets, id: \.id) { budget in
                        NavigationLink(destination: BudgetDetailView(budget: budget)) {
                            BudgetCardView(
                                name: budget.name ?? "Unnamed",
                                month: formattedMonth(budget.date),
                                isActive: budget.isActive
                            )
                            .contextMenu {
                                // Option to set the budget as active
                                Button(action: {
                                    setActiveBudget(budget)
                                }) {
                                    Label("Set Active", systemImage: "checkmark.circle.fill")
                                }
                                
                                // Option to delete the budget
                                Button(action: {
                                    deleteBudget(budget)
                                }) {
                                    Label("Delete", systemImage: "trash.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
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
            .onAppear {
                // Load budgets from Firebase (example userId: "sampleUserId")
                viewModel.fetchBudgets(for: "sampleUserId")
            }
        }
    }

    func formattedMonth(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }

    // Function to set a budget as active
    private func setActiveBudget(_ budget: BudgetModel) {
        viewModel.setActive(budget)
        
        // Update Core Data after setting active
        for item in budgets {
            item.isActive = false
        }
        
        // Set the selected budget as active
        if let selectedBudget = budgets.first(where: { $0.id == budget.id }) {
            selectedBudget.isActive = true
        }
        
        // Save changes to Core Data
        do {
            try viewContext.save()
        } catch {
            // Handle error
            print("Error saving active budget: \(error)")
        }
    }

    // Function to delete a budget
    private func deleteBudget(_ budget: BudgetModel) {
        viewModel.deleteBudget(budget)

        // Remove from Core Data
        if let localBudget = budgets.first(where: { $0.id == budget.id }) {
            viewContext.delete(localBudget)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting budget: \(error)")
            }
        }
    }
}

struct BudgetListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        return BudgetListView()
            .environment(\.managedObjectContext, context)
    }
}
