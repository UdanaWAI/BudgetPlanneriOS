import SwiftUI

struct GroupBudgetListView: View {
    @StateObject var viewModel: GroupBudgetViewModel
    @State private var showAddBudgetView = false
    @State private var selectedBudget: GroupBudgetModel? = nil

    var body: some View {
        NavigationView {
            List(viewModel.groupBudgets) { budget in
                VStack(alignment: .leading) {
                    Text(budget.name)
                        .font(.headline)
                    Text(budget.caption)
                        .font(.subheadline)
                    Text("Value: \(budget.value, specifier: "%.2f")")
                        .font(.subheadline)
                }
                .onTapGesture {
                    selectedBudget = budget
                }
            }
            .navigationTitle("Group Budgets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddBudgetView.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBudgetView) {
                CreateGroupBudgetView(viewModel: viewModel)
            }
            .background(
                NavigationLink(
                    destination: GroupBudgetDetailView(budget: selectedBudget),
                    isActive: .constant(selectedBudget != nil)
                ) {
                    EmptyView()
                }
            )
        }
    }
}
