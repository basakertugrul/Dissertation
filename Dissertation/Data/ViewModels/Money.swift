import Foundation

@Observable
class MoneyModel {
    var amount: Double
    var currencyCode: String

    private init(amount: Double, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }

    static func createWithPound(amount: Double) -> MoneyModel {
        return MoneyModel(amount: amount, currencyCode: "GBP")
    }

    init(from model: TargetSpendingModel) {
        self.amount             = model.amount
        self.currencyCode       = model.currencyCode ?? ""
    }
}

extension MoneyModel: Equatable {
    static func == (lhs: MoneyModel, rhs: MoneyModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension MoneyModel: Identifiable {}
