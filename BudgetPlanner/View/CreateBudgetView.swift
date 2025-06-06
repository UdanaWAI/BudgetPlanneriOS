import SwiftUI
import EventKit

struct CreateBudgetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var caption: String = ""
    @State private var value: Double = 0.0
    @State private var type: String = "Monthly"
    @State private var date: Date = Date()
    @State private var isRecurring = false
    @State private var setReminder = false

    
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
                HStack{
                    CheckboxView(isChecked: $isRecurring, label: "Set Recurring")
                    Spacer()
                    CheckboxView(isChecked: $setReminder, label: "Set Reminder")
                }.padding()
                
                Button(action: createBudget) {
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
    }

    func createBudget() {
        let newBudget = Budget(context: viewContext)
        newBudget.id = UUID()
        newBudget.name = name
        newBudget.caption = caption
        newBudget.value = value
        newBudget.type = type
        newBudget.date = date
        newBudget.isRecurring = isRecurring
        newBudget.setReminder = setReminder
        
        do {
            try viewContext.save()
            if setReminder {
                addBudgetReminderEvent(budgetName: name, startDate: date, type: type)
                   }
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving budget: \(error.localizedDescription)")
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
        let context = PersistenceController.shared.container.viewContext
        return CreateBudgetView()
            .environment(\.managedObjectContext, context)
    }
}
