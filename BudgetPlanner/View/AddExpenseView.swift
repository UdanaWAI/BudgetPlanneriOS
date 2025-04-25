import SwiftUI
import FirebaseFirestore

struct AddExpensesView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var budgetViewModel: BudgetViewModel
    var preselectedBudget: BudgetModel? = nil
    var onExpenseAdded: (() -> Void)? = nil

    @State private var selectedBudget: BudgetModel? = nil
    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var errorMessage: String = ""
    @State private var showReceiptScanner: Bool = false
    @State private var scannedText: String = ""

    @State private var navigateToBudgetList = false
    @State private var navigateToReports = false
    @State private var navigateToGroupBudgetList = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                Button(action: {
                    showReceiptScanner = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.viewfinder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.indigo)
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                }

                Spacer()

                if preselectedBudget == nil {
                    Section(header: Text("Add an Expense")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.indigo)) {
                        HStack {
                            Text(selectedBudget?.name ?? "Select a budget")
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                            Picker("", selection: $selectedBudget) {
                                ForEach(budgetViewModel.budgets, id: \.id) { budget in
                                    Text(budget.name).tag(Optional(budget))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .labelsHidden()
                            .accentColor(.indigo)
                        }
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                    }
                } else {
                    Section(header: Text("Budget")
                        .font(.caption)
                        .foregroundColor(.gray)) {
                        Text(preselectedBudget?.name ?? "")
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }
                }

                VStack(spacing: 15) {
                    TextBox(text: $name, placeholder: "Enter Expense Title", lable: "Title")
                    TextBox(text: $amount, placeholder: "Enter Amount", lable: "Amount")
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1))
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                }

                PrimaryButton(title: "Add Expense") {
                    addExpense()
                }
                .disabled(selectedBudget == nil && preselectedBudget == nil)

                Spacer()
                Spacer()

                SimpleTabBar { selectedTab in
                    switch selectedTab {
                    case .dashboard:
                        presentationMode.wrappedValue.dismiss()
                    case .personal:
                        navigateToBudgetList = true
                    case .expenses:
                        break
                    case .reports:
                        if let budget = selectedBudget ?? preselectedBudget {
                            navigateToReports = true
                        } else {
                            errorMessage = "Cannot open Reports. No budget selected."
                        }
                    case .group:
                        navigateToGroupBudgetList = true
                    }
                }
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 10)
            .background(
                NavigationLink(destination: ReportView(userId: selectedBudget?.userId ?? "", navigateBackToDashboard: .constant(false)), isActive: $navigateToReports) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: GroupBudgetListView(viewModel: GroupBudgetViewModel(userId: selectedBudget?.userId ?? ""), navigateBackToDashboard: .constant(false)), isActive: $navigateToGroupBudgetList) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(destination: BudgetListView(navigateBackToDashboard: $navigateToBudgetList), isActive: $navigateToBudgetList) {
                    EmptyView()
                }
            )
            .navigationBarBackButtonHidden(true)
            .onAppear {
                if let preselected = preselectedBudget {
                    selectedBudget = preselected
                }
            }
            .sheet(isPresented: $showReceiptScanner) {
                ReceiptScanner(scannedText: $scannedText, totalAmount: $amount)
            }
        }
    }

    func addExpense() {
        guard !name.isEmpty else {
            errorMessage = "Please enter a title."
            return
        }

        guard let amountDouble = Double(amount), amountDouble > 0 else {
            errorMessage = "Enter a valid amount."
            return
        }

        guard let budget = selectedBudget else {
            errorMessage = "Please select a budget."
            return
        }

        let db = Firestore.firestore()
        let expense = ExpenseModel(
            id: UUID().uuidString,
            name: name,
            amount: amountDouble,
            date: date,
            budgetID: budget.id
        )

        db.collection("expenses").document(expense.id).setData(expense.toDict()) { error in
            if let error = error {
                errorMessage = "Failed to save expense: \(error.localizedDescription)"
            } else {
                updateBudgetValue(by: amountDouble, for: budget)
                onExpenseAdded?()
                scheduleExpenseNotification(expense: expense)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    func updateBudgetValue(by spent: Double, for budget: BudgetModel) {
        let newValue = max(0, budget.value - spent)
        Firestore.firestore().collection("users")
            .document(budget.userId)
            .collection("budgets")
            .document(budget.id)
            .updateData(["value": newValue]) { error in
                if error == nil {
                    budget.value = newValue
                }
            }
    }

    func scheduleExpenseNotification(expense: ExpenseModel) {
        let content = UNMutableNotificationContent()
        content.title = "New Expense Added"
        content.body = "You have added a new expense: \(expense.name) for \(expense.amount) on \(expense.date.formatted(date: .abbreviated, time: .omitted))."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: expense.id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully with ID: \(expense.id)")
            }
        }
    }
}
