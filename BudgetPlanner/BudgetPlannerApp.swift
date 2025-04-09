//
//  BudgetPlannerApp.swift
//  BudgetPlanner
//
//  Created by Udana 004 on 2025-03-23.
//

import SwiftUI

@main
struct BudgetPlannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
                    BudgetListView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
    }
}
