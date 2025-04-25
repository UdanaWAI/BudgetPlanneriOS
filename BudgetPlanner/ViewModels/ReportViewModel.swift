import Foundation
import Combine
import FirebaseFirestore
import PDFKit

class ReportViewModel: ObservableObject {
    @Published var budgets: [BudgetModel] = []
    @Published var expenses: [ExpenseModel] = []
    @Published var reportData: [BudgetReport] = []

    private var cancellables = Set<AnyCancellable>()

    func fetchReport(for userId: String) {
        let db = Firestore.firestore()

        // Fetch Budgets
        db.collection("users").document(userId).collection("budgets").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            let budgets = documents.map { BudgetModel(from: $0.data()) }
            DispatchQueue.main.async {
                self.budgets = budgets
                self.fetchExpenses()
            }
        }
    }

    private func fetchExpenses() {
        let db = Firestore.firestore()

        db.collection("expenses").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            let expenses = documents.map { ExpenseModel(from: $0.data()) }
            DispatchQueue.main.async {
                self.expenses = expenses
                self.generateReport()
            }
        }
    }

    private func generateReport() {
        var report: [BudgetReport] = []

        for budget in budgets {
            let relatedExpenses = expenses.filter { $0.budgetID == budget.id }
            let totalSpent = relatedExpenses.reduce(0) { $0 + $1.amount }
            let remaining = budget.value - totalSpent
            let percentUsed = budget.value > 0 ? (totalSpent / budget.value) * 100 : 0

            let entry = BudgetReport(
                budgetName: budget.name,
                budgetType: budget.type,
                totalBudget: budget.value,
                totalSpent: totalSpent,
                remainingAmount: remaining,
                percentUsed: percentUsed,
                expenseCount: relatedExpenses.count
            )

            report.append(entry)
        }

        self.reportData = report
    }
    
    func generatePDFReport() -> Data? {
            let pdfMetaData = [
                kCGPDFContextCreator: "Budget App",
                kCGPDFContextAuthor: "Your App",
                kCGPDFContextTitle: "Budget Report"
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]

            let pageWidth = 612.0
            let pageHeight = 792.0
            let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

            let data = renderer.pdfData { context in
                context.beginPage()

                var yPos: CGFloat = 20

                let title = "Budget Report"
                title.draw(at: CGPoint(x: 20, y: yPos), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)])
                yPos += 40

                for report in reportData {
                    let budgetName = "Budget: \(report.budgetName)"
                    let spent = "Spent: \(String(format: "%.2f", report.totalSpent))"
                    let remaining = "Remaining: \(String(format: "%.2f", report.remainingAmount))"
                    let percent = "Used: \(String(format: "%.1f", report.percentUsed))%"

                    let content = "\(budgetName)\n\(spent)\n\(remaining)\n\(percent)\n\n"
                    content.draw(at: CGPoint(x: 20, y: yPos), withAttributes: [.font: UIFont.systemFont(ofSize: 16)])
                    yPos += 80
                }
            }

            return data
        }

        func sharePDF(data: Data) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("BudgetReport.pdf")
            do {
                try data.write(to: tempURL)
                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
            } catch {
                print("Failed to write PDF data: \(error)")
            }
        }
}
