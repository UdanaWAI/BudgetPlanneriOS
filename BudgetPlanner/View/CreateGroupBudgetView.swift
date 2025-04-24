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
    
    @State private var generatedJoinCode: String = UUID().uuidString.prefix(6).uppercased()
    @State private var isJoinCodeCopied = false

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

                Section(header: Text("Join Link")) {
                    HStack {
                        Text("Join Code:")
                        Spacer()
                        Text(generatedJoinCode)
                            .bold()
                        Button(action: {
                            let fullLink = "ntcbudget://join/\(generatedJoinCode)"
                            UIPasteboard.general.string = fullLink
                            isJoinCodeCopied = true
                        }) {
                            Image(systemName: isJoinCodeCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        }
                        .foregroundColor(.blue)
                    }

                    if isJoinCodeCopied {
                        Text("Link copied to clipboard!")
                            .font(.caption)
                            .foregroundColor(.green)
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
                            members: [viewModel.userId], // Only current user at creation
                            joinCode: generatedJoinCode
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
