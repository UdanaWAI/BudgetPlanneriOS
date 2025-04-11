import SwiftUI

struct ExpenseCardView: View {
    let expense: Expense
    let budgetValue: Double

    var progress: Double {
        guard budgetValue > 0 else { return 0 }
        return min(expense.amountSpent / budgetValue, 1.0)
    }

    var remaining: Double {
        max(0, budgetValue - expense.amountSpent)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top Section (Icon, Title, Budget)
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.purple)
                    .font(.title)
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(expense.title!)
                        .font(.headline)
                    Text("Spent: $\(expense.amountSpent, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // Progress Bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))

            HStack {
                Spacer()
                Text("Remaining: $\(remaining, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
