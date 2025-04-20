import SwiftUI

struct ContentView: View {
//    var body: some View {
//        BudgetListView()
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
    
    @EnvironmentObject var authVM: AuthViewModel

        var body: some View {
            if let _ = authVM.user {
                DashboardView()
            } else {
                LoginView()
            }
        }
}
