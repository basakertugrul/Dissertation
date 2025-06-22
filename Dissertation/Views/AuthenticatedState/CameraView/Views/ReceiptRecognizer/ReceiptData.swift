import Foundation

// MARK: - Receipt Data Model
struct ReceiptData: Equatable {
    var merchantName: String?
    var date: Date?
    var totalAmount: Double?

    var formattedDate: String? {
        guard let date = date else { return .none }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var formattedAmount: String? {
        guard let amount = totalAmount else { return .none }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current //TODO: use this logic everwhere () ask ai to make a logic for generating amount accordingly
        return formatter.string(from: NSNumber(value: amount))
    }
}
