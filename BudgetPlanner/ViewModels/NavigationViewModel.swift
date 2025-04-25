import SwiftUI

class NavigationViewModel: ObservableObject {
    @Published var selectedTab: TabDestination? = nil
}

enum TabDestination {
    case dashboard
    case budget
    case expenses
    case reports
    case groupBudget
}
