import UIKit
import Vision
import VisionKit

// MARK: - Receipt Text Recognizer
final class ReceiptTextRecognizer {

    // MARK: - Types
    typealias RecognitionResult = Result<ReceiptData, TextRecognitionError>
    typealias CompletionHandler = (RecognitionResult) -> Void

    // MARK: - Configuration
    private let recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    private let usesLanguageCorrection: Bool = true
    private let startDate: Date

    // MARK: - Initialization
    init(startDate: Date) {
        self.startDate = startDate
    }

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

        if receiptData.totalAmount ?? .zero > 0 {
            if isDateInRange(receiptData.date ?? .now, from: startDate, to: .now) {
                completion(.success(receiptData))
                return
            } else {
                completion(.failure(.outOfDateRange))
                return
            }
        }

        completion(.failure(.noResults))
        return
    }

    func isDateInRange(_ date: Date, from startDate: Date, to endDate: Date) -> Bool {
        return date >= startDate && date <= endDate
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
