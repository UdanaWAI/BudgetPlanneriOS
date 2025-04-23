import SwiftUI

struct DatePickerComponent: View {
    var label: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            HStack {
                Text("Select date")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .labelsHidden()
                .accentColor(.indigo)
            }
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

struct DatePickerComponent_Previews: PreviewProvider {
    @State static var previewDate = Date()

    static var previews: some View {
        DatePickerComponent(label: "Select Date", date: $previewDate)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
