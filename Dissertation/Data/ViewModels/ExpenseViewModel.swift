import Foundation

@Observable
class ExpenseViewModel {
    var name: String
    var date: Date
    var amount: Double
    let createDate: Date
    let id: UUID

    private init(
        name: String,
        date: Date,
        amount: Double,
        createDate: Date,
        id: UUID
    ) {
        self.name = name
        self.date = date
        self.amount = amount
        self.createDate = createDate
        self.id = id
    }

    func updateProperties(
        name: String,
        date: Date,
        amount: Double
    ) {
        self.name = name
        self.date = date
        self.amount = amount
    }

    static func create(
        id: UUID?,
        name: String,
        date: Date,
        amount: Double,
        createDate: Date
    ) -> ExpenseViewModel {
        return ExpenseViewModel(
            name: name,
            date: date,
            amount: amount,
            createDate: createDate,
            id: id ?? UUID()
        )
    }

    init(from model: ExpenseModel) {
        self.id         = model.id!
        self.name       = model.name ?? ""
        self.amount     = model.amount
        self.date       = model.date   ?? Date()
        self.createDate = model.createDate ?? Date()
    }

    func getDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
}

extension ExpenseViewModel: Equatable {
    static func == (lhs: ExpenseViewModel, rhs: ExpenseViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension ExpenseViewModel: Identifiable {}

/// Helper functions for dates
extension ExpenseViewModel {
    func isToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: Date())
    }

    func isYesterday() -> Bool {
        let calendar = Calendar.current
        let response = calendar.isDateInYesterday(date)
        return response
    }

    func isInLastWeek() -> Bool {
        let calendar = Calendar.current
        let response = calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        return response
    }

    func isInLastMonth() -> Bool {
        let calendar = Calendar.current
        let response = calendar.isDate(date, equalTo: Date(), toGranularity: .month)
        return response
    }

    func isInLastYear() -> Bool {
        let calendar = Calendar.current
        let response = calendar.isDate(date, equalTo: Date(), toGranularity: .year)
        return response
    }
}

func getAmountString(of amount: Double) -> String {
    let locale = Locale.current
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = locale
    return formatter.string(from: NSNumber(value: amount)) ?? "0.00"
}

func getCurrencySymbol() -> String {
    let locale = Locale.current
    return locale.currencySymbol ?? "$"
}
