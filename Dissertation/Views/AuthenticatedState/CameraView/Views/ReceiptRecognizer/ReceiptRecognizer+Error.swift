import Foundation

// MARK: - Receipt Error
enum TextRecognitionError: LocalizedError {
    case invalidImage
    case noResults
    case noTextFound
    case visionError(Error)
    case outOfDateRange

    var description: String {
        switch self {
        case .invalidImage:
            return "Photo quality is too poor. Please try taking a clearer picture."
        case .noResults:
            return "We couldn't read this image. Try taking a new photo with better lighting."
        case .noTextFound:
            return "No text detected. Make sure your receipt is clearly visible and try again."
        case .visionError:
            return "Something went wrong while processing your receipt. Please try again."
        case .outOfDateRange:
            return "This receipt appears to be very old. Please check and try again."
        }
    }
}
