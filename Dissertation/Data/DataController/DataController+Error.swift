import Foundation

// MARK: - Errors
enum DataControllerError: Error, LocalizedError {
    case saveFailure
    case deleteFailure
    case fetchFailure
    case updateFailure
    case expenseNotFound
    case dateParsingFailure
    case timeFrameNotFound
    case userNotAuthenticated
    case userDataMigrationFailure

    var errorDescription: String {
        switch self {
        case .saveFailure:
            return "Couldn't save your expense. Please try again."
        case .deleteFailure:
            return "Unable to delete expense. Please try again."
        case .fetchFailure:
            return "Couldn't load your expenses. Check your connection and try again."
        case .updateFailure:
            return "Failed to update expense. Please try again."
        case .expenseNotFound:
            return "This expense no longer exists."
        case .dateParsingFailure:
            return "Invalid date format. Please check your date settings."
        case .timeFrameNotFound:
            return "Unable to load your time preferences. Using default settings."
        case .userNotAuthenticated:
            return "Please sign in to access your data."
        case .userDataMigrationFailure:
            return "Failed to migrate your data. Please contact support."
        }
    }
}
