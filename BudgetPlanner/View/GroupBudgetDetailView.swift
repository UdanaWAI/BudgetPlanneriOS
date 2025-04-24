import SwiftUI

struct GroupBudgetDetailView: View {
    var budget: GroupBudgetModel?
    
    var body: some View {
        VStack {
            if let budget = budget {
                Text(budget.name)
                    .font(.title)
                Text(budget.caption)
                    .font(.subheadline)
                Text("Value: \(budget.value, specifier: "%.2f")")
                    .font(.subheadline)
                Text("Type: \(budget.type)")
                    .font(.subheadline)
                Text("Date: \(budget.date, style: .date)")
                    .font(.subheadline)
                Text("Recurring: \(budget.isRecurring ? "Yes" : "No")")
                    .font(.subheadline)
                Text("Reminder Set: \(budget.setReminder ? "Yes" : "No")")
                    .font(.subheadline)
                
                // Add more details as needed, such as the list of members
                List(budget.members, id: \.self) { member in
                    Text(member)
                }
            }
        }
        .navigationTitle("Group Budget Details")
        .padding()
    }
}
