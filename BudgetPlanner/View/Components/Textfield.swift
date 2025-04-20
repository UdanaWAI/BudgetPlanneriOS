import SwiftUI

// MARK: - TextBox Component
struct TextBox: View {
    @Binding var text: String
    var placeholder: String
    var lable: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lable)
                .font(.caption)
                .foregroundColor(.gray)

            TextField(placeholder, text: $text)
                .padding(.vertical,12).padding(.horizontal,10)
                .background(RoundedRectangle(cornerRadius: 10
                                            ).stroke(Color.gray.opacity(0.4)))
                .font(.system(size: 16))
        }
    }
}



struct Textfields: View {
    @State private var textValue = ""
    @State private var selectedBudget = "Monthly"
    
    var body: some View {
        VStack(spacing: 20) {
            TextBox(text: $textValue, placeholder: "Text input", lable: "Value")
            
        }
        .padding()
    }
}

struct Textfields_Previews: PreviewProvider {
    static var previews: some View {
        Textfields()
    }
}
