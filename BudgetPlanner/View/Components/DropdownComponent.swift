import SwiftUI

struct DropdownComponent: View {
    var label: String
    @Binding var selectedOption: String
    var options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                    }) {
                        Text(option)
                    }
                }
            } label: {
                HStack {
                    Text(selectedOption)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(.gray)
                        .imageScale(.small)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }
}


struct DropdownComponent_Previews: PreviewProvider {
    @State static var previewSelection = "Monthly"

    static var previews: some View {
        DropdownComponent(
            label: "Select Budget type",
            selectedOption: $previewSelection,
            options: ["Monthly", "Weekly", "Daily"]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
