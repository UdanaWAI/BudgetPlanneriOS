import SwiftUI

struct CustomBackButton: View {
    let title: String
    let foregroundColor: Color
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
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
