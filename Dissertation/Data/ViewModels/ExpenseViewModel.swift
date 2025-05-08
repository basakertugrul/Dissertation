import Foundation

@Observable
class ExpenseViewModel {
    var name: String
    var date: Date
    var amount: Double
    var currencyCode: String
    var createDate: Date
    var id: UUID = UUID()

    private init(
        name: String,
        date: Date,
        amount: Double,
        createDate: Date,
        currencyCode: String
    ) {
        self.name = name
        self.date = date
        self.amount = amount
        self.createDate = createDate
        self.currencyCode = currencyCode
    }

    static func createWithPound(name: String, date: Date, amount: Double, createDate: Date) -> ExpenseViewModel {
        return ExpenseViewModel(name: name, date: date, amount: amount, createDate: createDate, currencyCode: "GBP")
    }

    init(from model: ExpenseModel) {
        self.id         = model.id!
        self.name       = model.name ?? ""
        self.amount     = model.amount
        self.currencyCode   = model.currencyCode ?? ""
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

