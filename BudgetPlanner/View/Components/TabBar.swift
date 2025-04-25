import SwiftUI

struct SimpleTabBar: View {
    var onTabSelected: (TabItem) -> Void

    enum TabItem: String, CaseIterable {
        case dashboard = "house.fill"
        case personal = "person.fill"
        case expenses = "doc.text.fill"
        case reports = "chart.bar.fill"
        case group = "person.3.fill"
    }

    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { item in
                Spacer()
                Button(action: {
                    onTabSelected(item)
                }) {
                    Image(systemName: item.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
