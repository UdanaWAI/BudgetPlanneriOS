import SwiftUI

struct BudgetCardView: View {
    var name: String
    var month: String
    var isActive: Bool = false

    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.purple)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(month)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            if isActive {
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 1))
        .padding(.horizontal)
    }
}
