import SwiftUI
import Charts

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

enum ChartRange: String, CaseIterable {
    case oneWeek = "1W", oneMonth = "1M", threeMonths = "3M", sixMonths = "6M", oneYear = "1Y", all = "ALL"
}

struct ChartView: View {
    @State private var selectedRange: ChartRange = .oneWeek

    var body: some View {
        VStack(spacing: 16) {
            Picker("", selection: $selectedRange) {
                ForEach(ChartRange.allCases, id: \.self) { range in
                    Text(range.rawValue)
                        .tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ChartContent(data: getData(for: selectedRange))
        }
        .padding(.top)
    }

   func getData(for range: ChartRange) -> [ChartDataPoint] {
        switch range {
        case .oneWeek:
            return [
                .init(day: "MON", value: 100),
                .init(day: "TUE", value: 600),
                .init(day: "WED", value: 800),
                .init(day: "THR", value: 1600),
                .init(day: "FRI", value: 2300),
                .init(day: "SAT", value: 5000)
            ]
        default:
            return [
                .init(day: "MON", value: 200),
                .init(day: "TUE", value: 900),
                .init(day: "WED", value: 1200),
                .init(day: "THR", value: 1800),
                .init(day: "FRI", value: 2400),
                .init(day: "SAT", value: 4300)
            ]
        }
    }
}

struct ChartContent: View {
    let data: [ChartDataPoint]

    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .foregroundStyle(.blue)
                    
                    AreaMark(
                        x: .value("Day", point.day),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(.blue.opacity(0.2))
                }
                
                if let last = data.last {
                    PointMark(
                        x: .value("Day", last.day),
                        y: .value("Value", last.value)
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .top) {
                        Text("\(Int(last.value))")
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
            .frame(height: 240)
            .padding(.horizontal)
        } 
    }
}
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
