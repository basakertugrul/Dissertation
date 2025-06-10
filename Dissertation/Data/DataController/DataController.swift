import CoreData

struct DataController {
    public static let shared = DataController()
    /// Model Contianers
    let expenseModelContainer: NSPersistentContainer
    var expenseModelContext: NSManagedObjectContext {
        expenseModelContainer.viewContext
    }

    var targetSpendingModelContainer: NSPersistentContainer
    var targetSpendingModelContext: NSManagedObjectContext {
        targetSpendingModelContainer.viewContext
    }

    /// UserDefaults Keys
    private struct UserDefaultsKeys {
        static let timeFrame = "selectedTimeFrame"
        static let targetSpending = "targetSpendingAmount"
        static let startdate = "startDate"
    }

    private init() {
        expenseModelContainer = NSPersistentContainer(name: "ExpenseModel")
        expenseModelContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }

        targetSpendingModelContainer = NSPersistentContainer(name: "TargetSpendingModel")
        targetSpendingModelContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    // MARK: - TIME FRAME
    public func saveTimeFrame(_ timeFrame: TimeFrame) {
        UserDefaults.standard.set(timeFrame.rawValue, forKey: UserDefaultsKeys.timeFrame)
        print("✅ TimeFrame saved: \(timeFrame.rawValue)")
    }

    public func fetchTimeFrame() -> TimeFrame {
        let savedTimeFrameString = UserDefaults.standard.string(forKey: UserDefaultsKeys.timeFrame)

        if let savedTimeFrameString = savedTimeFrameString,
           let timeFrame = TimeFrame(rawValue: savedTimeFrameString) {
            return timeFrame
        }
        return .weekly
    }

    public func resetTimeFrame() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.timeFrame)
        print("🗑️ TimeFrame reset to default")
    }
    
    // MARK: - TARGET SPENDING MONEY
    public func saveTargetSpending(to amount: Double) {
        UserDefaults.standard.set(amount, forKey: UserDefaultsKeys.targetSpending)
        print("✅ Target Spending saved: £\(amount)")
        NotificationCenter.default.post(
            name: Notification.Name("TargetSpendingMoneyUpdated"),
            object: nil
        )
    }
    
    public func fetchTargetSpendingMoney() -> Double? {
        let savedAmount = UserDefaults.standard.double(forKey: UserDefaultsKeys.targetSpending)
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.targetSpending) != nil {
            print("✅ Target Spending fetched: £\(savedAmount)")
            return savedAmount
        } else {
            print("⚠️ No target spending found")
            return nil
        }
    }
    
    public func resetTargetSpending() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.targetSpending)
        print("🗑️ Target Spending reset to default")
        NotificationCenter.default.post(
            name: Notification.Name("TargetSpendingMoneyUpdated"),
            object: nil
        )
    }

    // MARK: - GENERAL
    public func save() {
        let expenseModelContext = expenseModelContainer.viewContext
        if expenseModelContext.hasChanges {
            do {
                try expenseModelContext.save()
            } catch {
                print(error)
            }
        }

        let targetSpendingModelContext = targetSpendingModelContainer.viewContext
        if targetSpendingModelContext.hasChanges {
            do {
                try targetSpendingModelContext.save()
            } catch {
                print(error)
            }
        }
    }

    // MARK: - EXPENSES
    public func saveExpense(of expense: ExpenseViewModel) {
        let newExpense = ExpenseModel(context: expenseModelContext)
        newExpense.amount = expense.amount
        newExpense.date = expense.date
        newExpense.id = expense.id
        newExpense.name = expense.name
        newExpense.currencyCode = expense.currencyCode
        newExpense.createDate = expense.createDate

        do {
            try expenseModelContext.save()
            print("✅ Expense saved")
            NotificationCenter.default.post(
                name: Notification.Name("ExpenseRefresh"),
                object: .none
            )
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }

    public func deleteExpense(of expense: ExpenseViewModel) {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)

        do {
            let results = try expenseModelContext.fetch(request)
            for expensex in results {
                expenseModelContext.delete(expensex)
            }
            try expenseModelContext.save()
            print("🗑️ Expense deleted")

            NotificationCenter.default.post(
                name: Notification.Name("ExpenseRefresh"),
                object: .none
            )
        } catch {
            print("❌ Failed to delete expense: \(error)")
        }
    }

    func updateExpense(of updatedExpense: ExpenseViewModel) {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", updatedExpense.id as CVarArg)

        do {
            let results = try expenseModelContext.fetch(request)
            guard let existingExpense = results.first else {
                print("⚠️ No matching expense found to update")
                return
            }

            existingExpense.name = updatedExpense.name
            existingExpense.amount = updatedExpense.amount
            existingExpense.currencyCode = updatedExpense.currencyCode
            existingExpense.date = updatedExpense.date
            existingExpense.createDate = updatedExpense.createDate

            try expenseModelContext.save()
            print("✅ Expense updated")
            NotificationCenter.default.post(
                name: Notification.Name("ExpenseRefresh"),
                object: .none
            )
        } catch {
            print("❌ Failed to update expense: \(error)")
        }
    }

    public func resetExpenses() {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()

        do {
            let results = try expenseModelContext.fetch(request)
            for targetSpending in results {
                expenseModelContext.delete(targetSpending)
            }
            try expenseModelContext.save()
            print("🗑️")
            NotificationCenter.default.post(
                name: Notification.Name("ExpenseRefresh"),
                object: .none
            )
        } catch {
            print("❌: \(error)")
        }
    }

    public func fetchExpenses() -> [ExpenseViewModel] {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()

        do {
            let result = try expenseModelContext.fetch(request)
            return result.map {
                ExpenseViewModel(from: $0)
            }
        } catch {
            print("❌ Failed to fetch expenses: \(error)")
            return []
        }
    }

    // MARK: - START DAY
    func fetchTargetSetDate() -> Date? {
        let savedDate = UserDefaults.standard.string(forKey: UserDefaultsKeys.startdate)
        if let savedDate = savedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: savedDate)
        }
        return nil
    }

    func saveTargetSetDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        UserDefaults.standard.set(dateString, forKey: UserDefaultsKeys.startdate)
        print("✅ Start date saved: £\(dateString)")
    }
}
