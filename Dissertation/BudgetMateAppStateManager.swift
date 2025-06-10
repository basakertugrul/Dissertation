import Foundation

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    public static let shared = AppStateManager()
 
    private init() {
        self.dailyBalance = .zero
        self.expenseViewModels = []
        self.startDate = .now
    }

    @Published var dailyBalance: Double
    @Published var expenseViewModels: [ExpenseViewModel]
    @Published var startDate: Date
    private let dataController = DataController.shared

    /// Days since the app start date was set
    var daysSinceStart: Int {
        let calendar = Calendar.current
        return (calendar.dateComponents([.day],
                                     from: calendar.startOfDay(for: startDate),
                                     to: calendar.startOfDay(for: Date())).day ?? 0) + 1
    }

    /// Total budget accumulated since start date
    var totalBudgetAccumulated: Double {
        dailyBalance * Double(daysSinceStart)
    }

    var totalExpenses: Double {
        expenseViewModels.reduce(0) { $0 + $1.amount }
    }

    /// Improved balance calculation using start date
    var calculatedBalance: Double {
        totalBudgetAccumulated - totalExpenses
    }

    func loadInitialData() {
        refreshDailyBalance()
        refreshExpenses()
        loadOrSetStartDate()
    }

    func refreshDailyBalance() {
        dailyBalance = dataController.fetchTargetSpendingMoney() ?? 0
    }

    func refreshExpenses() {
        expenseViewModels = dataController.fetchExpenses()
    }
    
    /// Load existing start date or set new one if it doesn't exist
    private func loadOrSetStartDate() {
        if let existingStartDate = dataController.fetchTargetSetDate() {
            // Start date exists, use it
            startDate = existingStartDate
            print("✅ Loaded existing start date: \(existingStartDate)")
        } else {
            // No start date exists, set to today
            startDate = Date()
            dataController.saveTargetSetDate(startDate)
            print("⏰ Set new start date: \(startDate)")
        }
    }

    /// Update start date and save to storage
    func updateStartDate(_ newDate: Date) {
        startDate = newDate
        dataController.saveTargetSetDate(newDate)
        print("🔄 Updated start date to: \(newDate)")
    }
    
    /// Reset start date to today
    func resetStartDate() {
        updateStartDate(Date())
    }
}
