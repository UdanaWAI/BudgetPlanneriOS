import SwiftUI

struct CreateGroupBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GroupBudgetViewModel

    @State private var name = ""
    @State private var caption = ""
    @State private var value: Double = 0.0
    @State private var type = "Monthly"
    @State private var date = Date()
    @State private var isRecurring = false
    @State private var setReminder = false

    @State private var generatedJoinCode: String = UUID().uuidString.prefix(6).uppercased()
    @State private var isJoinCodeCopied = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CustomBackButton(title: "Create Group Budget", foregroundColor: .indigo)

                Image(systemName: "person.3.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                    .padding()

                TextFieldComponent(title: "Budget Name", text: $name)
                TextFieldComponent(title: "Caption", text: $caption)
                NumberInputComponent(title: "Value", value: $value)
                DropdownComponent(label: "Select Budget Type", selectedOption: $type, options: ["Monthly", "Weekly", "Daily"])
                DatePickerComponent(label: "Select Date", date: $date)

                HStack {
                    CheckboxView(isChecked: $isRecurring, label: "Recurring")
                    Spacer()
                    CheckboxView(isChecked: $setReminder, label: "Set Reminder")
                }
                .padding(.horizontal)

                HStack(spacing: 8) {
                    Text("Join Code:")
                        .font(.headline)

                    HStack {
                        Text(generatedJoinCode)
                            .font(.system(.body, design: .monospaced))
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)

                        Button(action: {
                            let fullLink = "ntcbudget://join/\(generatedJoinCode)"
                            UIPasteboard.general.string = fullLink
                            isJoinCodeCopied = true
                        }) {
                            Image(systemName: isJoinCodeCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                .foregroundColor(isJoinCodeCopied ? .green : .blue)
                        }
                    }

                    if isJoinCodeCopied {
                        Text("Link copied to clipboard!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding()

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    PrimaryButton(title: "Save Budget", action: saveGroupBudget)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationBarBackButtonHidden(true)
    }

    func saveGroupBudget() {
        isLoading = true
        errorMessage = nil

        let newBudget = GroupBudgetModel(
            name: name,
            caption: caption,
            value: value,
            type: type,
            date: date,
            isRecurring: isRecurring,
            setReminder: setReminder,
            userId: viewModel.userId,
            members: [viewModel.userId],
            joinCode: generatedJoinCode
        )

        viewModel.addGroupBudget(newBudget)
        isLoading = false
        presentationMode.wrappedValue.dismiss()
    }
}
