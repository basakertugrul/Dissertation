import Foundation

struct ExpenseMetrics {
    let daysSinceEarliest: Int
    let totalExpenses: Double
    let calculatedBalance: Double

    init(expenseViewModels: [ExpenseViewModel], dailyBalance: Double) {
        self.daysSinceEarliest = Self.calculateDaysSinceEarliest(from: expenseViewModels)
        self.totalExpenses = expenseViewModels.reduce(0) { $0 + $1.amount }
        self.calculatedBalance = dailyBalance * Double(daysSinceEarliest) - totalExpenses
    }

    private static func calculateDaysSinceEarliest(from viewModels: [ExpenseViewModel]) -> Int {
        guard let earliestDate = viewModels.map({ $0.date }).min() else { return 0 }
        return Calendar.current.dateComponents([.day],
                                             from: Calendar.current.startOfDay(for: earliestDate),
                                             to: Calendar.current.startOfDay(for: Date())).day ?? 0
    }
}
