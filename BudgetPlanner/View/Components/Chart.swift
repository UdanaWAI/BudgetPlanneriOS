import SwiftUI
import Charts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

enum ChartRange: String, CaseIterable {
    case oneWeek = "1W", oneMonth = "1M", oneYear = "1Y", all = "ALL"
}

struct BudgetChartView: View {
    @StateObject private var viewModel = ReportViewModel()
    let userId: String
    @State private var selectedRange: ChartRange = .oneMonth
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("", selection: $selectedRange) {
                ForEach(ChartRange.allCases, id: \.self) { range in
                    Text(range.rawValue)
                        .tag(range)
                        .foregroundColor(.indigo)
                }
            }
            .pickerStyle(.segmented)
            .background(Color.indigo.opacity(0.8))
            .cornerRadius(8)
            .frame(width: 280)
            
            ChartContent(data: getChartData(for: selectedRange))
        }
        .padding(.top)
        .onAppear {
            viewModel.fetchReport(for: userId)
        }
    }
    
    func getChartData(for range: ChartRange) -> [ChartDataPoint] {
        
        var chartData: [ChartDataPoint] = []
        
        for report in viewModel.reportData {
         
            chartData.append(ChartDataPoint(day: report.budgetName, value: report.totalSpent))
        }
        
        return chartData
    }
}

struct ChartContent: View {
    let data: [ChartDataPoint]

    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Budget", point.day),
                        y: .value("Amount", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .foregroundStyle(.blue)
                    
                    PointMark(
                        x: .value("Budget", point.day),
                        y: .value("Amount", point.value)
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .top) {
                        Text("\(Int(point.value))")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(width:300, height: 300)
            .padding(.horizontal)
        }
    }
}

struct BudgetChartView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetChartView(userId: "exampleUserId")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
