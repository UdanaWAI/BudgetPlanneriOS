import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Your Dashboard")
                    .font(.title)
                    .padding()

                // Navigation to Budget List
                NavigationLink(destination: BudgetListView()) {
                    HStack {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Manage Budgets")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                // Add other dashboard buttons here
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}
