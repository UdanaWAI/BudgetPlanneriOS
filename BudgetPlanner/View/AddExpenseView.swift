import SwiftUI
import CoreData

struct CreateExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var amountSpent: Double = 0.0
    @State private var isRecurring: Bool = false
    @State private var selectedBudgetID: UUID?  // Store the UUID of the selected budget

    var selectedBudget: Budget? // <-- Add this

        @FetchRequest(
            entity: Budget.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Budget.name, ascending: true)]
        ) var budgets: FetchedResults<Budget>

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Expense")
                    .font(.title2)
                    .padding(.top)

                Image(systemName: "creditcard.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.purple)
                    .padding()

                TextFieldComponent(title: "Expense Title", text: $title)
                NumberInputComponent(title: "Amount Spent", value: $amountSpent)
                
                // Select Budget Picker
                Picker("Select Budget", selection: $selectedBudgetID) {
                    ForEach(budgets, id: \.self) { budget in
                        Text(budget.name!)
                            .tag(budget.id)
                    }
                } 
                .pickerStyle(MenuPickerStyle())
                .padding()

                HStack {
                    CheckboxView(isChecked: $isRecurring, label: "Is Recurring")
                }.padding()
                
                Button(action: createExpense) {
                    Text("Create")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            if let selected = selectedBudget {
                            selectedBudgetID = selected.id
                        }
        }
    }

    func createExpense() {
        guard let selectedBudgetID = selectedBudgetID,
              let selectedBudget = budgets.first(where: { $0.id == selectedBudgetID }) else {
            print("No budget selected!")
            return
        }

        let newExpense = Expense(context: viewContext)
        newExpense.id = UUID()
        newExpense.title = title
        newExpense.amountSpent = amountSpent
        newExpense.isRecurring = isRecurring
        newExpense.date = Date()
        newExpense.budget = selectedBudget  // Assign selected Budget object

        selectedBudget.value = max(0, selectedBudget.value - amountSpent)

        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving expense: \(error.localizedDescription)")
        }
    }
}

struct CreateExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        // Insert mock budget data to show in Picker preview
        let mockBudget = Budget(context: context)
        mockBudget.id = UUID()
        mockBudget.name = "Mock Budget"
        mockBudget.value = 1000
        mockBudget.type = "Monthly"
        mockBudget.date = Date()
        mockBudget.isRecurring = false
        mockBudget.setReminder = false
        mockBudget.caption = "Preview Caption"
        mockBudget.isActive = true

        do {
            try context.save()
        } catch {
            print("Failed to save preview budget: \(error)")
        }

        return CreateExpenseView()
            .environment(\.managedObjectContext, context)
    }
}
