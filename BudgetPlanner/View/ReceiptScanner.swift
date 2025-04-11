import SwiftUI
import VisionKit
import Vision

struct ReceiptScanner: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Binding var totalAmount: String  // New Binding for total cost
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerVC = VNDocumentCameraViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ReceiptScanner

        init(_ parent: ReceiptScanner) {
            self.parent = parent
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var scannedText = ""
            for pageIndex in 0..<scan.pageCount {
                let scannedImage = scan.imageOfPage(at: pageIndex)
                recognizeText(from: scannedImage)
            }
            controller.dismiss(animated: true)
        }

        func recognizeText(from image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            let request = VNRecognizeTextRequest { (request, error) in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }

                var recognizedText = ""
                for observation in observations {
                    if let topCandidate = observation.topCandidates(1).first {
                        recognizedText += "\(topCandidate.string)\n"
                    }
                }

                DispatchQueue.main.async {
                    self.parent.scannedText = recognizedText
                    self.parent.totalAmount = self.extractTotalAmount(from: recognizedText)  // Auto-fill total
                }
            }

            request.recognitionLevel = .accurate
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }

        func extractTotalAmount(from text: String) -> String {
            let pattern = #"(?i)(Total|Amount|Rs.|Grand\s?Total|Balance\s?Due)[\s:\-]*([A-Z]{2,4}[:\s]*)*([0-9,]+\.[0-9]{2})"#

            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range),
                   let amountRange = Range(match.range(at: 3), in: text) {

                    let value = text[amountRange]
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    return value
                }
            }

            return "Not Found"
        }



    }
}
