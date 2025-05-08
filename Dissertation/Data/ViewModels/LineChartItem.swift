import Foundation

struct LineChartItem: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let moneySpent: Double
    let currency: String

    var currencySymbol: String {
        switch currency {
        case "USD":
            return "$"
        case "GBP":
            return "£"
        default:
            return "£"
        }
    }
    var animate: Bool = false

    private init(date: Date, moneySpent: Double, currency: String) {
        self.date = date
        self.moneySpent = moneySpent
        self.currency = currency
    }

    static func createWithPound(date: Date, moneySpent: Double) -> Self {
        return LineChartItem(date: date, moneySpent: moneySpent, currency: "GBP")
    }

    func getRevenue(goalMoneySpent: Double) -> Double {
        return goalMoneySpent - moneySpent
    }
}
