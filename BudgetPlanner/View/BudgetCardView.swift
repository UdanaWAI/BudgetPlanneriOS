import SwiftUI
import CoreData

struct BudgetListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Budget.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Budget.date, ascending: false)]
    ) private var budgets: FetchedResults<Budget>
    
    // Track the active budget in the UI state
    @State private var activeBudget: Budget? = nil

    var body: some View {
        NavigationView {
            VStack {
                Text("Personal Budget List")
                    .font(.title2)
                    .padding(.top)

                ScrollView {
                    ForEach(budgets, id: \.id) { budget in
                        // Swipe actions for both left and right swipe
                        BudgetCardView(name: budget.name ?? "Unnamed", month: formattedMonth(budget.date), isActive: budget == activeBudget)
                            .swipeActions(edge: .trailing) {
                                // Right swipe - Set as active
                                Button(action: {
                                    setActiveBudget(budget)
                                }) {
                                    Label("Set Active", systemImage: "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .leading) {
                                // Left swipe - Delete
                                Button(action: {
                                    deleteBudget(budget)
                                }) {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                                .tint(.red)
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
        }
    }

    func formattedMonth(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }

    // Function to set a budget as active
    private func setActiveBudget(_ budget: Budget) {
        // First, set all budgets to inactive
        for item in budgets {
            item.isActive = false
        }
        
        // Set the selected budget as active
        budget.isActive = true
        activeBudget = budget

        // Save changes to Core Data
        do {
            try viewContext.save()
        } catch {
            // Handle error
            print("Error saving active budget: \(error)")
        }
    }

    // Function to delete a budget
    private func deleteBudget(_ budget: Budget) {
        viewContext.delete(budget)

        // Save changes to Core Data
        do {
            try viewContext.save()
        } catch {
            // Handle error
            print("Error deleting budget: \(error)")
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

