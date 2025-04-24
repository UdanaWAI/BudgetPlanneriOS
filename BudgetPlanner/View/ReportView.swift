import SwiftUI

struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    let userId: String
    @Binding var navigateBackToDashboard: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            CustomCancelButton(title: "Budget Reports", foregroundColor: .indigo) {
                navigateBackToDashboard = false
            }
            .padding(.top, 10)
            BudgetChartView(userId: userId)
                .padding(.top,30)
                .padding(.vertical,10)
            
            List(viewModel.reportData) { report in
                VStack(alignment: .leading, spacing: 6) {
                    Text(report.budgetName)
                        .font(.headline)
                    ProgressView(value: report.percentUsed, total: 100)
                        .accentColor(report.percentUsed > 100 ? .red : .green)
                    HStack {
                        Text("Spent: \(report.totalSpent, specifier: "%.2f")")
                        Spacer()
                        Text("Remaining: \(report.remainingAmount, specifier: "%.2f")")
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 6)
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            viewModel.fetchReport(for: userId)
        }
    }
}
