import SwiftUI

struct ExpenseCardView: View {
    let categoryTitle: String
    let categoryBudget: Double
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top Section (Icon, Title, Budget)
            HStack {
                Image(systemName: "car.fill") // Replace with your custom icon
                    .foregroundColor(.purple)
                    .font(.title)
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(categoryTitle)
                        .font(.headline)
                    Text("$\(categoryBudget, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Expense Items List
            ForEach(expenses) { expense in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(expense.title)
                            .font(.subheadline)
                            .bold()
                        
                        Spacer()
                        
                        Text("$\(expense.amountSpent, specifier: "%.2f")")
                            .bold()
                    }
                    
                    // Progress Bar
                    ProgressView(value: expense.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                    
                    HStack {
                        Spacer()
                        Text("Left $\(expense.remaining, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}


struct ExpenseCardView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseCardView(
            categoryTitle: "Auto & Transport",
            categoryBudget: 700,
            expenses: [
                Expense(title: "Auto & transport", amountSpent: 350, totalBudget: 536),
                Expense(title: "Auto insurance", amountSpent: 250, totalBudget: 370),
                Expense(title: "Auto", amountSpent: 250, totalBudget: 370)
            ]
        )
    }
}


