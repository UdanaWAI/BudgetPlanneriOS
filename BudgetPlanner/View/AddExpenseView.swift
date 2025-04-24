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

    var body: some View {
        NavigationView {
            Form {
                if preselectedBudget == nil {
                    Section(header: Text("Choose a Budget")) {
                        Picker("Budget", selection: $selectedBudget) {
                            ForEach(budgetViewModel.budgets, id: \.id) { budget in
                                Text(budget.name).tag(Optional(budget))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                } else {
                    Section(header: Text("Budget")) {
                        Text(preselectedBudget?.name ?? "")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Expense Info")) {
                    TextField("Title", text: $name)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Button(action: addExpense) {
                    Text("Add Expense")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(selectedBudget == nil && preselectedBudget == nil)

                Button(action: {
                    showReceiptScanner = true
                }) {
                    Text("Scan Receipt")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .sheet(isPresented: $showReceiptScanner) {
                ReceiptScanner(scannedText: $scannedText, totalAmount: $amount)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CustomCancelButton(title: "Add an Expense", foregroundColor: .blue) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let preselected = preselectedBudget {
                selectedBudget = preselected
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
