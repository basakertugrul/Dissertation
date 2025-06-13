import Foundation

// MARK: - Receipt Error
enum TextRecognitionError: LocalizedError {
    case invalidImage
    case noResults
    case noTextFound
    case visionError(Error)
    
    var errorDescription: String {
        switch self {
        case .invalidImage:
            return "Invalid image provided"
        case .noResults:
            return "No text recognition results found"
        case .noTextFound:
            return "No text found in image"
        case let .visionError(error):
            return "Vision framework error: \(error.localizedDescription)"
        }
    }
}
