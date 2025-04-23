import SwiftUI

struct ExpenseCardView: View {
    let expense: ExpenseModel
    let budgetValue: Double

    private let themeColor: Color = ExpenseCardView.randomThemeColor()

    static func randomThemeColor() -> Color {
        let colors: [Color] = [.blue, .green, .orange, .cyan, .purple, .red, .teal, .yellow]
            return colors.randomElement() ?? .purple }
    
    private var iconName: String {
            let lowercasedName = expense.name.lowercased()

            if lowercasedName.contains("food") || lowercasedName.contains("lunch") || lowercasedName.contains("dinner") || lowercasedName.contains("snack") {
                return "fork.knife"
            } else if lowercasedName.contains("bill") {
                return "doc.text.fill"
            } else if lowercasedName.contains("fuel") || lowercasedName.contains("car") || lowercasedName.contains("vehicle") || lowercasedName.contains("transport") {
                return "car.fill"
            } else {
                return "creditcard.fill"
            }
        }
    
    var progress: Double {
        guard budgetValue > 0 else { return 0 }
        return min(expense.amount / budgetValue, 1.0)
    }

    var remaining: Double {
        max(0, budgetValue - expense.amount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
           
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(themeColor)
                    .font(.title)
                    .padding()
                    .background(themeColor.opacity(0.2))
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(expense.name)
                        .font(.headline)
                    Text("Spent: $\(expense.amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: themeColor))

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
