import SwiftUI

struct CreateGroupBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GroupBudgetViewModel
    @State private var name = ""
    @State private var caption = ""
    @State private var value: Double = 0.0
    @State private var type = ""
    @State private var date = Date()
    @State private var isRecurring = false
    @State private var setReminder = false
    @State private var membersString = "" // Temporary string for the text field input
    @State private var members: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget Details")) {
                    TextField("Name", text: $name)
                    TextField("Caption", text: $caption)
                    TextField("Value", value: $value, format: .currency(code: "USD"))
                    TextField("Type", text: $type)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Recurring", isOn: $isRecurring)
                    Toggle("Set Reminder", isOn: $setReminder)
                }
                
                Section(header: Text("Members")) {
                    TextField("Add Members (comma separated)", text: $membersString)
                        .onChange(of: membersString) { newValue in
                            // Split the string into members when the user types
                            self.members = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        }
                }
                
                Section {
                    Button("Save Budget") {
                        let newBudget = GroupBudgetModel(
                            name: name,
                            caption: caption,
                            value: value,
                            type: type,
                            date: date,
                            isRecurring: isRecurring,
                            setReminder: setReminder,
                            userId: viewModel.userId,
                            members: members
                        )
                        
                        viewModel.addGroupBudget(newBudget)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Create Group Budget")
        }
    }
}
