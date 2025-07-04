import Foundation

// MARK: - Time Frame Model
enum TimeFrame: CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly

    var localizedString: String {
        switch self {
        case .daily:
            return NSLocalizedString("daily", comment: "")
        case .weekly:
            return  NSLocalizedString("weekly", comment: "")
        case .monthly:
            return NSLocalizedString("monthly", comment: "")
        case .yearly:
            return NSLocalizedString("yearly", comment: "")
        }
    }

    init?(from string: String) {
           switch string.lowercased() {
           case "daily": self = .daily
           case "weekly": self = .weekly
           case "monthly": self = .monthly
           case "yearly": self = .yearly
           default: return nil
           }
       }
}
