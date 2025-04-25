import SwiftUI

struct SimpleTabBar: View {
    var onTabSelected: (TabItem) -> Void

    enum TabItem: String, CaseIterable {
        case dashboard = "house.fill"
        case personal = "chart.pie.fill"
        case expenses = "plus.circle.fill"
        case group = "person.3.fill"
        case reports = "chart.line.uptrend.xyaxis"
        

        var label: String {
            switch self {
            case .dashboard: return "Home"
            case .personal: return "Budget"
            case .expenses: return "Expense"
            case .group: return "Group"
            case .reports: return "Reports"
            
            }
        }
    }

    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { item in
                Spacer()
                Button(action: {
                    onTabSelected(item)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: item.rawValue)
                            .font(.system(size: 28))
                            .foregroundColor(Color.indigo)
                        Text(item.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.indigo)
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 20)
        .background(Color.white)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: -2)
    }
}
