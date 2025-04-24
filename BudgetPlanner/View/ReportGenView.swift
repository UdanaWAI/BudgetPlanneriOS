//import Foundation
//import PDFKit
//import UIKit
//
//class ReportPDFGenerator {
//    static func generateReport(for budget: BudgetModel, expenses: [ExpenseModel]) -> Data {
//        let pdfMetaData = [
//            kCGPDFContextCreator: "BudgetApp",
//            kCGPDFContextAuthor: "Your Name",
//            kCGPDFContextTitle: "Budget Report"
//        ]
//        let format = UIGraphicsPDFRendererFormat()
//        format.documentInfo = pdfMetaData as [String: Any]
//
//        let pageWidth = 595.2
//        let pageHeight = 841.8
//        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
//
//        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
//
//        let data = renderer.pdfData { context in
//            context.beginPage()
//            let context = context.cgContext
//
//            var yPosition: CGFloat = 40
//
//            func drawText(_ text: String, font: UIFont = .systemFont(ofSize: 16, weight: .regular), offset: CGFloat = 20) {
//                let paragraphStyle = NSMutableParagraphStyle()
//                paragraphStyle.alignment = .left
//
//                let attributes: [NSAttributedString.Key: Any] = [
//                    .font: font,
//                    .paragraphStyle: paragraphStyle
//                ]
//
//                let attributedText = NSAttributedString(string: text, attributes: attributes)
//                attributedText.draw(at: CGPoint(x: 30, y: yPosition))
//                yPosition += offset
//            }
//
//            
//            drawText("Total Value: $\(String(format: "%.2f", budget.value))")
//            let totalSpent = expenses.reduce(0) { $0 + $1.amount }
//            drawText("Total Spent: $\(String(format: "%.2f", totalSpent))")
//            drawText("Remaining: $\(String(format: "%.2f", budget.value - totalSpent))", offset: 30)
//
//            drawText("Expenses Breakdown", font: .boldSystemFont(ofSize: 18), offset: 30)
//
//            for expense in expenses {
//                drawText("• \(expense.name): $\(String(format: "%.2f", expense.amount)) on \(formatDate(expense.date))")
//            }
//        }
//
//        return data
//    }
//
//    private static func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter.string(from: date)
//    }
//}
