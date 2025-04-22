//import SwiftUI
//
//struct ContentView: View {
////    var body: some View {
////        BudgetListView()
////    }
////}
////
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ContentView()
////    }
//    
//    @EnvironmentObject var authVM: AuthViewModel
//
//        var body: some View {
//            if let _ = authVM.user {
//                DashboardView()
//            } else {
//                LoginView()
//            }
//        }
//}
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel  // Access the AuthViewModel

    var body: some View {
        if let _ = authVM.user {
            // If user is logged in, show Dashboard
            DashboardView()
                .environmentObject(authVM)  // Pass authVM to DashboardView
        } else {
            // If user is logged out, show LoginView
            LoginView()
                .environmentObject(authVM)  // Pass authVM to LoginView
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel()) // Provide the AuthViewModel here
    }
}
