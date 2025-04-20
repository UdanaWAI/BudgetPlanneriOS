import SwiftUI
import Firebase
import FirebaseCore

@main
struct BudgetPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    @StateObject private var authVM = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authVM.user != nil {
                    DashboardView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
                else {
                    LoginView()
                }
            }
            .environmentObject(authVM)
        }
    }
}
