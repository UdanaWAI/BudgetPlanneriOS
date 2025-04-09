import SwiftUI

struct SectionCardView: View {
    var icon: String
    var title: String
    var total: Double
    var spent: Double

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                Text(title)
                    .font(.headline)
                Spacer()
                Text("$\(spent, specifier: "%.2f") / $\(total, specifier: "%.2f")")
                    .font(.caption)
            }

            ProgressView(value: spent, total: total)
                .accentColor(.purple)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
