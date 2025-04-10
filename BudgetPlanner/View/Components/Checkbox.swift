import SwiftUI

struct CheckboxView: View {
    @Binding var isChecked: Bool
    var label: String

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square" : "square")
                    .foregroundColor(isChecked ? .purple : .gray)
                    .font(.title2)
                    .padding(.trailing, 5)

                Text(label)
                    .foregroundColor(.black)
                    .font(.body)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

