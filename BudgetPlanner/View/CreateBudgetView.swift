import SwiftUI
import EventKit
import FirebaseFirestore
//import FirebaseFirestoreSwift

struct CreateBudgetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authVM: AuthViewModel

    @State private var name: String = ""
    @State private var caption: String = ""
    @State private var value: Double = 0.0
    @State private var type: String = "Monthly"
    @State private var date: Date = Date()
    @State private var isRecurring = false
    @State private var setReminder = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let db = Firestore.firestore()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Personal Budget")
                    .font(.title2)
                    .padding(.top)

                Image(systemName: "chart.pie.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.purple)
                    .padding()

                TextFieldComponent(title: "Budget Name", text: $name)
                TextFieldComponent(title: "Caption", text: $caption)
                NumberInputComponent(title: "Value", value: $value)
                DropdownComponent(label: "Select Budget Type", selectedOption: $type, options: ["Monthly", "Weekly", "Daily"])
                DatePickerComponent(label: "Select Date", date: $date)

                HStack {
                    CheckboxView(isChecked: $isRecurring, label: "Set Recurring")
                    Spacer()
                    CheckboxView(isChecked: $setReminder, label: "Set Reminder")
                }.padding()

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                Button(action: createBudget) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(10)
                    } else {
                        Text("Create")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)
                .padding(.horizontal)
            }
        }
        .padding()
    }

    func createBudget() {
        guard let userId = authVM.user?.id else {
            errorMessage = "User not logged in."
            return
        }

        isLoading = true
        errorMessage = nil

        // Generate a unique UUID for the budget's ID
        let budgetID = UUID().uuidString

        // Manually convert the BudgetModel to a dictionary
        let budgetDict: [String: Any] = [
            "id": budgetID,
            "userId": userId,
            "name": name,
            "caption": caption,
            "value": value,
            "type": type,
            "date": date,
            "isRecurring": isRecurring,
            "setReminder": setReminder
        ]

        db.collection("users").document(userId).collection("budgets").document(budgetID).setData(budgetDict) { error in
            isLoading = false
            if let error = error {
                self.errorMessage = "Failed to save to Firebase: \(error.localizedDescription)"
                return
            }

            // Save to Core Data after Firebase is successful
            saveToCoreData(firebaseID: budgetID)

            if setReminder {
                addBudgetReminderEvent(budgetName: name, startDate: date, type: type)
            }

            presentationMode.wrappedValue.dismiss()
        }
    }


    func saveToCoreData(firebaseID: String) {
        let localBudget = Budget(context: viewContext)
        localBudget.id = UUID()  // Store a UUID for Core Data
        localBudget.name = name
        localBudget.caption = caption
        localBudget.value = value
        localBudget.type = type
        localBudget.date = date
        localBudget.isRecurring = isRecurring
        localBudget.setReminder = setReminder
        localBudget.firebaseID = firebaseID  // Store Firebase document ID
        localBudget.userId = authVM.user?.id

        do {
            try viewContext.save()
        } catch {
            print("Failed to save to Core Data: \(error.localizedDescription)")
        }
    }
}

func addBudgetReminderEvent(budgetName: String, startDate: Date, type: String) {
    let eventStore = EKEventStore()

    eventStore.requestAccess(to: .event) { granted, error in
        if granted && error == nil {
            let event = EKEvent(eventStore: eventStore)
            event.title = "Budget Reminder: \(budgetName)"
            event.startDate = startDate
            event.endDate = startDate.addingTimeInterval(60 * 60) // 1-hour duration
            event.calendar = eventStore.defaultCalendarForNewEvents

            // Set recurrence rule based on budget type
            var recurrenceFrequency: EKRecurrenceFrequency?
            switch type.lowercased() {
            case "daily":
                recurrenceFrequency = .daily
            case "weekly":
                recurrenceFrequency = .weekly
            case "monthly":
                recurrenceFrequency = .monthly
            default:
                break
            }

            if let frequency = recurrenceFrequency {
                let recurrenceRule = EKRecurrenceRule(
                    recurrenceWith: frequency,
                    interval: 1,
                    end: nil
                )
                event.recurrenceRules = [recurrenceRule]
            }

            do {
                try eventStore.save(event, span: .futureEvents)
                print("Recurring event added to calendar.")
            } catch let err {
                print("Failed to save event: \(err.localizedDescription)")
            }
        } else {
            print("Calendar access denied or error: \(error?.localizedDescription ?? "Unknown")")
        }
    }
}

struct CreateBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Dummy AuthViewModel for preview with mock user
        let authVM = AuthViewModel()
        authVM.user = AppUser(id: "test-id", username: "Test User", mobile: "123456", email: "test@example.com")
        
        return CreateBudgetView()
            .environment(\.managedObjectContext, context)
            .environmentObject(authVM)
    }
}
