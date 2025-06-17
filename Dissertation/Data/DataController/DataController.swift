import CoreData

// MARK: - DataController Errors
enum DataControllerError: Error, LocalizedError {
    case saveFailure
    case deleteFailure
    case fetchFailure
    case updateFailure
    case expenseNotFound
    case dateParsingFailure
    case timeFrameNotFound

    var errorDescription: String {
        switch self {
        case .saveFailure:
            return "Couldn't save your expense. Please try again."
        case .deleteFailure:
            return "Unable to delete expense. Please try again."
        case .fetchFailure:
            return "Couldn't load your expenses. Check your connection and try again."
        case .updateFailure:
            return "Failed to update expense. Please try again."
        case .expenseNotFound:
            return "This expense no longer exists."
        case .dateParsingFailure:
            return "Invalid date format. Please check your date settings."
        case .timeFrameNotFound:
            return "Unable to load your time preferences. Using default settings."
        }
    }
}

struct DataController {
    public static let shared = DataController()
    
    /// Model Containers
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
    public func saveTimeFrame(_ timeFrame: TimeFrame) -> Result<Void, DataControllerError> {
        UserDefaults.standard.set(timeFrame.rawValue, forKey: UserDefaultsKeys.timeFrame)
        return .success(())
    }

    public func fetchTimeFrame() -> Result<TimeFrame, DataControllerError> {
        let savedTimeFrameString = UserDefaults.standard.string(forKey: UserDefaultsKeys.timeFrame)
        if let savedTimeFrameString = savedTimeFrameString,
           let timeFrame = TimeFrame(rawValue: savedTimeFrameString) {
            return .success(timeFrame)
        }
        return .success(.weekly)
    }

    public func resetTimeFrame() -> Result<Void, DataControllerError> {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.timeFrame)
        print("🗑️ TimeFrame reset to default")
        return .success(())
    }

    // MARK: - TARGET SPENDING MONEY
    public func saveTargetSpending(to amount: Double) -> Result<Void, DataControllerError> {
        UserDefaults.standard.set(amount, forKey: UserDefaultsKeys.targetSpending)
        print("✅ Target Spending saved: £\(amount)")
        NotificationCenter.default.post(
            name: Notification.Name("TargetSpendingMoneyUpdated"),
            object: nil
        )
        return .success(())
    }

    public func fetchTargetSpendingMoney() -> Result<Double?, DataControllerError> {
        let savedAmount = UserDefaults.standard.double(forKey: UserDefaultsKeys.targetSpending)
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.targetSpending) != nil {
            return .success(savedAmount)
        } else {
            return .success(nil)
        }
    }

    public func resetTargetSpending() -> Result<Void, DataControllerError> {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.targetSpending)
        print("🗑️ Target Spending reset to default")
        NotificationCenter.default.post(
            name: Notification.Name("TargetSpendingMoneyUpdated"),
            object: nil
        )
        return .success(())
    }

    // MARK: - GENERAL
    public func save() -> Result<Void, DataControllerError> {
        do {
            let expenseModelContext = expenseModelContainer.viewContext
            if expenseModelContext.hasChanges {
                try expenseModelContext.save()
            }
            let targetSpendingModelContext = targetSpendingModelContainer.viewContext
            if targetSpendingModelContext.hasChanges {
                try targetSpendingModelContext.save()
            }
            return .success(())
        } catch {
            return .failure(.saveFailure)
        }
    }

    // MARK: - EXPENSES
    public func saveExpense(of expense: ExpenseViewModel) -> Result<Void, DataControllerError> {
        do {
            let newExpense = ExpenseModel(context: expenseModelContext)
            newExpense.amount = expense.amount
            newExpense.date = expense.date
            newExpense.id = expense.id
            newExpense.name = expense.name
            newExpense.currencyCode = expense.currencyCode
            newExpense.createDate = expense.createDate
            try expenseModelContext.save()
            NotificationCenter.default.post(
                name: Notification.Name("ExpenseRefresh"),
                object: .none
            )
            return .success(())
        } catch {
            return .failure(.saveFailure)
        }
    }

    public func deleteExpense(of expense: ExpenseViewModel) -> Result<Void, DataControllerError> {
        do {
            let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
            let results = try expenseModelContext.fetch(request)
            guard !results.isEmpty else {
                return .failure(.expenseNotFound)
            }
            for expenseModel in results {
                expenseModelContext.delete(expenseModel)
            }
            try expenseModelContext.save()
            NotificationCenter.default.post(
                name: Notification.Name("ExpenseRefresh"),
                object: .none
            )
            return .success(())
        } catch {
            return .failure(.deleteFailure)
        }
    }

    func updateExpense(of updatedExpense: ExpenseViewModel) -> Result<Void, DataControllerError> {
        do {
            let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", updatedExpense.id as CVarArg)
            let results = try expenseModelContext.fetch(request)
            guard let existingExpense = results.first else {
                print("⚠️ No matching expense found to update")
                return .failure(.expenseNotFound)
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
            return .success(())
        } catch {
            return .failure(.updateFailure)
        }
    }

    public func resetExpenses() -> Result<Void, DataControllerError> {
        do {
            let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
            let results = try expenseModelContext.fetch(request)
            for expense in results {
                expenseModelContext.delete(expense)
            }
            try expenseModelContext.save()
            print("🗑️ All expenses deleted")
            NotificationCenter.default.post(
                name: Notification.Name("ExpenseRefresh"),
                object: .none
            )
            return .success(())
        } catch {
            return .failure(.deleteFailure)
        }
    }

    public func fetchExpenses() -> Result<[ExpenseViewModel], DataControllerError> {
        do {
            let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
            let result = try expenseModelContext.fetch(request)
            let expenses = result.map { ExpenseViewModel(from: $0) }
            return .success(expenses)
        } catch {
            return .failure(.fetchFailure)
        }
    }

    // MARK: - START DAY
    func fetchTargetSetDate() -> Result<Date?, DataControllerError> {
        guard let savedDate = UserDefaults.standard.string(forKey: UserDefaultsKeys.startdate) else {
            return .success(nil)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: savedDate) else {
            return .failure(.dateParsingFailure)
        }
        return .success(date)
    }

    func saveTargetSetDate(_ date: Date) -> Result<Void, DataControllerError> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        UserDefaults.standard.set(dateString, forKey: UserDefaultsKeys.startdate)
        return .success(())
    }
}
