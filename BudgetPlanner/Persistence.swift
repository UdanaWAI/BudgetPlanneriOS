import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // MARK: - Preview Support for SwiftUI Previews
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Add mock budgets for preview/testing
        for index in 0..<3 {
            let budget = Budget(context: viewContext)
            budget.id = UUID()
            budget.name = "Mock Budget \(index + 1)"
            budget.caption = "Preview Caption \(index + 1)"
            budget.value = Double(index + 1) * 100
            budget.type = "Monthly"
            budget.date = Date()
            budget.setReminder = false
            budget.isRecurring = false
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    // MARK: - Core Data Stack
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BudgetPlanner") // Match your .xcdatamodeld file name
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
