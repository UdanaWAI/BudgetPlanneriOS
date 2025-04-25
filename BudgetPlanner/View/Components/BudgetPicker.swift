import SwiftUI

struct ChooseBudgetComponent: View {
    var label: String
    @Binding var selectedBudget: BudgetModel?
    var budgets: [BudgetModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                Text(selectedBudget?.name ?? "Select a budget")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Picker("", selection: $selectedBudget) {
                    ForEach(budgets, id: \.id) { budget in
                        Text(budget.name).tag(Optional(budget))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .labelsHidden()
                .accentColor(.indigo)
            }
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

