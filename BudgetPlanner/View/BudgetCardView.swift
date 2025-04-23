import SwiftUI

struct BudgetListView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedBudget: BudgetModel?

    var body: some View {
        NavigationView {
            VStack {
               ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 30)
                       .fill(Color.indigo)
                        .frame(height: 130)
                        .edgesIgnoringSafeArea(.top)
                    
                   CustomBackButton(title: "Personal Budget List", foregroundColor:Color.white)
                        .padding(.leading, 10)
                        .padding(.top, 10)
                }.frame(maxWidth: .infinity)
                
                ScrollView {
                    ForEach(viewModel.budgets) { budget in
                        NavigationLink(
                            destination: BudgetDetailView(budget: budget),
                            tag: budget,
                            selection: $selectedBudget
                        ) {
                            BudgetCardView(
                                name: budget.name,
                                month: formattedMonth(budget.date),
                                isActive: budget.isActive
                            ).padding(.top,10)
                            .contextMenu {
                                Button(action: {
                                    setActiveBudget(budget)
                                }) {
                                    Label("Set Active", systemImage: "checkmark.circle.fill")
                                }

                                Button(role: .destructive) {
                                    deleteBudget(budget)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }.padding(.top, -30)

                NavigationLink(destination: CreateBudgetView()) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Budget")
                    }
                    .padding()
                    .foregroundColor(Color.indigo)
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(50)
                }
                .padding()
            }.navigationBarBackButtonHidden(true)
            .onAppear {
                if let userId = authVM.user?.id {
                    viewModel.fetchBudgets(for: userId)
                }
            }
        }.navigationBarBackButtonHidden(true)
    }

    func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }

    private func setActiveBudget(_ selected: BudgetModel) {
        viewModel.setActive(selected)
    }

    private func deleteBudget(_ budget: BudgetModel) {
        viewModel.deleteBudget(budget)
    }
}

struct BudgetListView_Previews: PreviewProvider {
    static var previews: some View {
   
        let mockUser = AppUser(id: "user123", username: "Jane Doe", mobile: "1234567890", email: "jane@example.com")

        let mockAuthVM = AuthViewModel()
        mockAuthVM.user = mockUser

        let mockBudgets = [
            BudgetModel(id: "1", name: "Groceries", caption: "Monthly food budget", value: 500.0, type: "Food", date: Date(), isRecurring: true, setReminder: true, isActive: true, userId: mockUser.id ?? ""),
            BudgetModel(id: "2", name: "Entertainment", caption: "For movies and outings", value: 200.0, type: "Leisure", date: Date(), isRecurring: false, setReminder: false, isActive: false, userId: mockUser.id ?? "")
        ]

        let mockBudgetVM = BudgetViewModel()
        mockBudgetVM.budgets = mockBudgets

        return BudgetListView()
            .environmentObject(mockAuthVM)
            .environmentObject(mockBudgetVM)
            .previewDevice("iPhone 14")
    }
}

