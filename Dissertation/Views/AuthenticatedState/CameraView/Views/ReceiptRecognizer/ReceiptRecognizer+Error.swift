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
            return NSLocalizedString("invalid_image_error", comment: "")
        case .noResults:
            return NSLocalizedString("no_results_error", comment: "")
        case .noTextFound:
            return NSLocalizedString("no_text_found_error", comment: "")
        case .visionError:
            return NSLocalizedString("vision_error", comment: "")
        case .outOfDateRange:
            return NSLocalizedString("out_of_date_range_error", comment: "")
        }
    }
}
