import SwiftUI

// MARK: - CameraManager Extension
extension CameraManager {
    public func processReceiptImage(
        _ image: UIImage,
        completion: @escaping (Result<ReceiptData, TextRecognitionError>) -> Void
    ) {
        let recognizer = ReceiptTextRecognizer()
        recognizer.recognizeReceiptData(from: image, completion: completion)
    }
}
