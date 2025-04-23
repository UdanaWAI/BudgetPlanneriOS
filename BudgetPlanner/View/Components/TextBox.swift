import SwiftUI

struct TextFieldComponent: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            TextField("", text:$text).padding(12).background(Color(.white)).cornerRadius(10).overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                
        }
        .padding(.horizontal)
    }
}

struct TextFieldComponent_Previews: PreviewProvider {
    @State static var sampleText = "Preview text"

    static var previews: some View {
        TextFieldComponent(title: "Name", text: $sampleText)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
