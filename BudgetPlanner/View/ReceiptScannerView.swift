import SwiftUI
import VisionKit

struct ReceiptScannerView: View {
    @State private var totalCost: String = ""      // Automatically updated with only total
    @State private var showScanner = false         // Controls camera sheet

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Receipt Scanner")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Button(action: {
                    showScanner = true
                }) {
                    Text("Scan Receipt")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .sheet(isPresented: $showScanner) {
                    ReceiptScanner(scannedText: .constant(""), totalAmount: $totalCost)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Cost:")
                        .font(.headline)

                    TextField("Total", text: $totalCost)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                         // Make it read-only
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Receipt Scanner")
        }
    }
}

struct ReceiptScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptScannerView()
    }
}
