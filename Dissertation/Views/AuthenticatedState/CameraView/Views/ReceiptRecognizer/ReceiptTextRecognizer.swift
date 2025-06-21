import UIKit
import Vision
import VisionKit

// MARK: - Receipt Text Recognizer
class ReceiptTextRecognizer {
    
    // MARK: - Types
    typealias RecognitionResult = Result<ReceiptData, TextRecognitionError>
    typealias CompletionHandler = (RecognitionResult) -> Void
    
    // MARK: - Configuration
    private let recognitionLevel: VNRequestTextRecognitionLevel
    private let usesLanguageCorrection: Bool
    
    // MARK: - Initialization
    init(recognitionLevel: VNRequestTextRecognitionLevel = .accurate,
         usesLanguageCorrection: Bool = true) {
        self.recognitionLevel = recognitionLevel
        self.usesLanguageCorrection = usesLanguageCorrection
    }

    func recognizeReceiptData(from image: UIImage, completion: @escaping CompletionHandler) {
        guard let cgImage = image.cgImage else {
            completion(.failure(.invalidImage))
            return
        }

        performTextRecognition(on: cgImage, completion: completion)
    }
    
    func recognizeReceiptData(from images: [UIImage]) {
        guard !images.isEmpty else { return }

        for image in images {
            recognizeReceiptData(from: image) { result in
                print("---")
                switch result {
                case let .success(data):
                    print("Merchant: \(data.merchantName ?? "Unknown")")
                    print("Date: \(data.formattedDate ?? "Unknown")")
                    print("Amount: \(data.formattedAmount ?? "Unknown")")

                case let .failure(error):
                    print("Error: \(error)")
                }
            }
        }
    }
}

// MARK: - Private Methods
private extension ReceiptTextRecognizer {
    func performTextRecognition(on cgImage: CGImage, completion: @escaping CompletionHandler) {
        let request = createTextRecognitionRequest(completion: completion)
        let handler = VNImageRequestHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
        } catch {
            completion(.failure(.visionError(error)))
        }
    }

    func createTextRecognitionRequest(completion: @escaping CompletionHandler) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { [weak self] request, error in
            self?.handleVisionResult(request: request, error: error, completion: completion)
        }

        request.recognitionLevel = recognitionLevel
        request.usesLanguageCorrection = usesLanguageCorrection

        return request
    }
    
    func handleVisionResult(request: VNRequest, error: Error?, completion: @escaping CompletionHandler) {
        if let error = error {
            completion(.failure(.visionError(error)))
            return
        }

        guard let observations = request.results as? [VNRecognizedTextObservation],
              !observations.isEmpty else {
            completion(.failure(.noResults))
            return
        }

        let recognizedText = extractText(from: observations)

        guard !recognizedText.isEmpty else {
            completion(.failure(.noTextFound))
            return
        }

        let receiptData = createReceiptData(from: recognizedText)
        completion(.success(receiptData))
    }

    func extractText(from observations: [VNRecognizedTextObservation]) -> String {
        observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }
    
    func createReceiptData(from text: String) -> ReceiptData {
        let extractor = ReceiptDataExtractor(text: text)
    
        return ReceiptData(
            merchantName: extractor.merchantName,
            date: extractor.date,
            totalAmount: extractor.amount
        )
    }
}

// MARK: - Receipt Data Extractor
struct ReceiptDataExtractor {
    let lines: [String]
    
    init(text: String) {
        self.lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var merchantName: String? {
        extractMerchantName(from: lines)
    }
    
    var date: Date? {
        extractDate(from: lines)
    }
    
    var amount: Double? {
        extractAmount(from: lines)
    }
}
