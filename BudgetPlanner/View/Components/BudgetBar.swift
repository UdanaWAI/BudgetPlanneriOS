
import SwiftUI

struct BudgetView: View {
    var currentBalance: Double
    var expenses: Double
    var monthlyBudget: Double

    private var expensePercentage: Double {
        expenses / monthlyBudget
    }

    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(Color.indigo)
                .frame(height: 3)
                .cornerRadius(1.5)
                .padding(.horizontal)
                            
            Text("Current Balance")
                .font(.headline)
                .foregroundColor(.indigo)

            Text("$\(Int(currentBalance))")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.indigo)

            Text("March 2025")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                VStack(alignment: .leading) {
                    Text("Expenses")
                        .font(.subheadline)
                    Text("$\(Int(expenses))")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Monthly budget")
                        .font(.subheadline)
                    Text("$\(Int(monthlyBudget))")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)

            ProgressView(value: expensePercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .indigo))
                .frame(height: 8)
                .padding(.horizontal)
            Divider()
            Spacer()
            
        }
        .padding()
        
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(currentBalance: 1812, expenses: 1230, monthlyBudget: 2000)
    }
}
