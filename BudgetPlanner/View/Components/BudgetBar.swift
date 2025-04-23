
import SwiftUI

struct BudgetView: View {
    var title: String
    var currentBalance: Double
    var expenses: Double
    var monthlyBudget: Double
    var monthYear: String

    private var expensePercentage: Double {
        expenses / monthlyBudget
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Image(systemName: "wallet.pass")
                .foregroundColor(.indigo)
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.indigo)
                Spacer() }
            .padding(.horizontal)
            
            Rectangle()
                .fill(Color.indigo)
                .frame(height: 3)
                .cornerRadius(1.5)
                .padding(.horizontal)
                .padding(.bottom,20)
                            
            Text("Current Balance")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.indigo)

            Text("$\(Int(currentBalance))")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.indigo)

            Text(monthYear)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.indigo)

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
        .padding(.top,20)
        
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(title: "Personal Budget", currentBalance: 1812, expenses: 1230, monthlyBudget: 2000, monthYear: "March 2025")
    }
}
