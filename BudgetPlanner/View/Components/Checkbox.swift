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
                    .foregroundColor(isChecked ? .indigo : .gray)
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

struct CheckboxView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxView(isChecked: .constant(false), label: "I agree to the terms")
            .padding()
    }
}
