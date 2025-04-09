import SwiftUI

struct DatePickerComponent: View {
    var label: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            DatePicker(selection: $date, displayedComponents: .date) {
                Text("")
            }
            .datePickerStyle(CompactDatePickerStyle())
        }
        .padding(.horizontal)
    }
}
