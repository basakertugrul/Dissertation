import UIKit
import Vision
import VisionKit

// MARK: - Receipt Text Recognizer
final class ReceiptTextRecognizer {
    
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

    // MARK: - Public Method
    func recognizeReceiptData(from image: UIImage, completion: @escaping CompletionHandler) {
        guard let cgImage = image.cgImage else {
            completion(.failure(.invalidImage))
            return
        }

        performTextRecognition(on: cgImage, completion: completion)
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
            totalAmount: extractor.amount,
            rawText: text
        )
    }
}

// MARK: - Receipt Data Extractor
struct ReceiptDataExtractor {
    let text: String
    let lines: [String]
    
    init(text: String) {
        self.text = text
        self.lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var merchantName: String? {
        extractMerchantName(from: lines)
    }
    
    var date: Date? {
        extractDate(from: lines, text)
    }
    
    var amount: Double? {
        extractAmount()
    }
}
