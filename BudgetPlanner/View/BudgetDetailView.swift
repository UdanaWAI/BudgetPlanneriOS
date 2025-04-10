import SwiftUI

struct BudgetDetailView: View {
    var budget: Budget

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 10) {
                Text(budget.name ?? "No Name")
                    .font(.title)
                    .bold()
                Text("Current Balance")
                    .font(.caption)
                Text("$\(budget.value, specifier: "%.2f")")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.purple)

                Text(formattedMonth(budget.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Divider()

                Text("Caption: \(budget.caption ?? "-")")
                    .font(.body)
                Text("Budget Type: \(budget.type ?? "-")")
                    .font(.body)
                Divider()
                CheckboxView(isChecked: .constant(budget.isRecurring), label: "Set Recurring")
                CheckboxView(isChecked: .constant(budget.setReminder), label: "Set Reminder")

            }
            .padding()
            Spacer()
        }
        .navigationTitle("Personal Budget")
    }

    func formattedMonth(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}

struct BudgetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let sample = Budget(context: context)
        sample.id = UUID()
        sample.name = "Sample Budget"
        sample.caption = "A preview budget"
        sample.value = 300.0
        sample.type = "Monthly"
        sample.date = Date()

        return BudgetDetailView(budget: sample)
    }
}

