import Foundation

// MARK: - LineChartItem structure
struct LineChartItem {
    let id = UUID()
    let date: Date
    let moneySpent: Double
    
    static func create(date: Date, moneySpent: Double) -> LineChartItem {
        return LineChartItem(
            date: date,
            moneySpent: moneySpent
        )
    }
}

extension LineChartItem: Equatable {
    static func == (lhs: LineChartItem, rhs: LineChartItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.moneySpent == rhs.moneySpent &&
               lhs.date == rhs.date
    }
}
