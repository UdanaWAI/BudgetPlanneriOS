import SwiftUI

struct NumberInputComponent: View {
    var title: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            TextField(title, value: $value, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
                .padding(12).background(Color(.white)).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.4), lineWidth: 1))
            
        }
        .padding(.horizontal)
    }
}
