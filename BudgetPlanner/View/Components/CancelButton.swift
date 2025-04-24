import SwiftUI

struct CustomAddExpenseButton: View {
    let title: String
    let foregroundColor: Color
    var action: (() -> Void)? = nil
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Button(action: {
                if let action = action {
                    action()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text(title)
                        .fontWeight(.medium)
                }
                .foregroundColor(foregroundColor)
                .font(.headline)
            }
            Spacer()
        }
        .padding([.top, .horizontal])
    }
}
