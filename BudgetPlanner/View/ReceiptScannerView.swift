import SwiftUI
import VisionKit

struct ReceiptScannerView: View {
    @State private var totalCost: String = ""  // Automatically updated
    @State private var scannedItems: String = ""
    @State private var showScanner = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Receipt Scanner")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Button(action: {
                    showScanner = true
                }) {
                    Text("Scan Receipt")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showScanner) {
                    ReceiptScanner(scannedText: $scannedItems, totalAmount: $totalCost)  // Pass bindings
                }

                Text("Total Cost:")
                    .font(.headline)

                TextField("Total Cost", text: $totalCost)  // Auto-filled
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disabled(true)  // Read-only

                ScrollView {
                    Text(scannedItems.isEmpty ? "Scanned items will appear here." : scannedItems)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding()

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
