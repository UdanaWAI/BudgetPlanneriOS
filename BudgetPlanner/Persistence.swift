//
//  Persistence.swift
//  BudgetPlanner
//
//  Created by Udana 004 on 2025-03-23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Preview context for SwiftUI previews
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add some mock Budget data for preview/testing
        for index in 0..<5 {
            let budget = Budget(context: viewContext)
            budget.id = UUID()
            budget.name = "Mock Budget \(index + 1)"
            budget.caption = "Preview Caption \(index + 1)"
            budget.value = Double(index + 1) * 100
            budget.type = "Monthly"
            budget.date = Date()
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BudgetPlanner") // Must match your .xcdatamodeld file name
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Handle the error properly in a real app (logging, fallback, user notification, etc.)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
