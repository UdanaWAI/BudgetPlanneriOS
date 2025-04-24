import SwiftUI

struct GroupBudgetListView: View {
    @StateObject var viewModel: GroupBudgetViewModel
    @State private var showAddBudgetView = false
    @State private var selectedBudget: GroupBudgetModel? = nil
    @Binding var navigateBackToDashboard: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.indigo)
                    .frame(height: 130)
                    .edgesIgnoringSafeArea(.top)

                CustomCancelButton(title: "Group Budget List", foregroundColor: .white) {
                    navigateBackToDashboard = false
                }
                .padding(.top, 10)
            }

            ScrollView {
                ForEach(viewModel.groupBudgets) { budget in
                    NavigationLink(
                        destination: GroupBudgetDetailView(budget: budget),
                        tag: budget,
                        selection: $selectedBudget
                    ) {
                        BudgetCardView(
                            name: budget.name,
                            month: formattedMonth(budget.date)
                        )
                        .padding(.top, 10)
                        .contextMenu {
                            Button(action: {
                                
                            }) {
                                Label("Set Active", systemImage: "checkmark.circle.fill")
                            }

                            Button(role: .destructive) {
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, -30)

            NavigationLink(destination: CreateGroupBudgetView(viewModel: viewModel)) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create New Group Budget")
                }
                .padding()
                .foregroundColor(Color.indigo)
                .background(Color.indigo.opacity(0.1))
                .cornerRadius(50)
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchGroupBudgets()
        }
        .navigationBarBackButtonHidden(true)
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }
}
