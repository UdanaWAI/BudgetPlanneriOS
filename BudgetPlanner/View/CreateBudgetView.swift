import SwiftUI

struct CreateBudgetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var caption: String = ""
    @State private var value: Double = 0.0
    @State private var type: String = "Monthly"
    @State private var date: Date = Date()

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

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving budget: \(error.localizedDescription)")
        }
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
