import CoreData
import Foundation

// MARK: - Enhanced DataController with User Support
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
    
    // Current user from auth service
    private var currentUser: User? {
        UserAuthService.shared.currentUser
    }
    
    private var currentUserId: String? {
        currentUser?.id.uuidString
    }

    /// UserDefaults Keys (now user-specific)
    private struct UserDefaultsKeys {
        static func timeFrame(for userId: String) -> String { "user_\(userId)_selectedTimeFrame" }
        static func targetSpending(for userId: String) -> String { "user_\(userId)_targetSpendingAmount" }
        static func startDate(for userId: String) -> String { "user_\(userId)_startDate" }
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
    
    // MARK: - User Validation
    private func validateUser() -> Result<String, DataControllerError> {
        guard let userId = currentUserId else {
            return .failure(.userNotAuthenticated)
        }
        return .success(userId)
    }

    // MARK: - TIME FRAME
    public func saveTimeFrame(_ timeFrame: TimeFrame) -> Result<Void, DataControllerError> {
        switch validateUser() {
        case .success(let userId):
            UserDefaults.standard.set(timeFrame.localizedString, forKey: UserDefaultsKeys.timeFrame(for: userId))
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    public func fetchTimeFrame() -> TimeFrame {
        guard case .success(let userId) = validateUser() else {
            return .weekly // Default fallback
        }
        
        let savedTimeFrameString = UserDefaults.standard.string(forKey: UserDefaultsKeys.timeFrame(for: userId))
        if let savedTimeFrameString = savedTimeFrameString,
           let timeFrame = TimeFrame(from: savedTimeFrameString) {
            return timeFrame
        }
        return .weekly
    }

    public func resetTimeFrame() -> Result<Void, DataControllerError> {
        switch validateUser() {
        case .success(let userId):
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.timeFrame(for: userId))
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - TARGET SPENDING MONEY
    public func saveTargetSpending(to amount: Double) -> Result<Void, DataControllerError> {
        switch validateUser() {
        case .success(let userId):
            do {
                // Check if target spending already exists for this user
                let request: NSFetchRequest<TargetSpendingModel> = TargetSpendingModel.fetchRequest()
                request.predicate = NSPredicate(format: "userID == %@", userId)
                let results = try targetSpendingModelContext.fetch(request)
                
                let targetSpending: TargetSpendingModel
                if let existing = results.first {
                    // Update existing
                    targetSpending = existing
                } else {
                    // Create new
                    targetSpending = TargetSpendingModel(context: targetSpendingModelContext)
                    targetSpending.userID = userId
                }
                
                targetSpending.amount = amount
                try targetSpendingModelContext.save()
                
                NotificationCenter.default.post(
                    name: Notification.Name("TargetSpendingMoneyUpdated"),
                    object: nil
                )
                return .success(())
            } catch {
                return .failure(.saveFailure)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    public func fetchTargetSpendingMoney() -> Result<Double?, DataControllerError> {
        switch validateUser() {
        case .success(let userId):
            do {
                let request: NSFetchRequest<TargetSpendingModel> = TargetSpendingModel.fetchRequest()
                request.predicate = NSPredicate(format: "userID == %@", userId)
                let results = try targetSpendingModelContext.fetch(request)
                
                if let targetSpending = results.first {
                    return .success(targetSpending.amount)
                } else {
                    return .success(nil)
                }
            } catch {
                return .failure(.fetchFailure)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    public func resetTargetSpending() -> Result<Void, DataControllerError> {
        switch validateUser() {
        case .success(let userId):
            do {
                let request: NSFetchRequest<TargetSpendingModel> = TargetSpendingModel.fetchRequest()
                request.predicate = NSPredicate(format: "userID == %@", userId)
                let results = try targetSpendingModelContext.fetch(request)
                
                for targetSpending in results {
                    targetSpendingModelContext.delete(targetSpending)
                }
                
                try targetSpendingModelContext.save()
                NotificationCenter.default.post(
                    name: Notification.Name("TargetSpendingMoneyUpdated"),
                    object: nil
                )
                return .success(())
            } catch {
                return .failure(.deleteFailure)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: - EXPENSES
    public func saveExpense(of expense: ExpenseViewModel) -> Result<Void, DataControllerError> {
        switch validateUser() {
        case let .success(userId):
            do {
                let newExpense = ExpenseModel(context: expenseModelContext)
                newExpense.amount = expense.amount
                newExpense.date = expense.date
                newExpense.id = expense.id
                newExpense.name = expense.name
                newExpense.createDate = expense.createDate
                newExpense.userID = userId
                
                try expenseModelContext.save()
                NotificationCenter.default.post(
                    name: Notification.Name("ExpenseRefresh"),
                    object: .none
                )
                return .success(())
            } catch {
                return .failure(.saveFailure)
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    public func deleteExpense(of expense: ExpenseViewModel) -> Result<Void, DataControllerError> {
        switch validateUser() {
        case .success(let userId):
            do {
                let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND userID == %@",
                                              expense.id as CVarArg, userId)
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
        case .failure(let error):
            return .failure(error)
        }
    }

    func updateExpense(of updatedExpense: ExpenseViewModel) -> Result<Void, DataControllerError> {
        switch validateUser() {
        case let .success(userId):
            do {
                let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND userID == %@",
                                              updatedExpense.id as CVarArg, userId)
                let results = try expenseModelContext.fetch(request)
                guard let existingExpense = results.first else {
                    return .failure(.expenseNotFound)
                }
                existingExpense.name = updatedExpense.name
                existingExpense.amount = updatedExpense.amount
                existingExpense.date = updatedExpense.date
                existingExpense.createDate = updatedExpense.createDate
                
                try expenseModelContext.save()
                NotificationCenter.default.post(
                    name: Notification.Name("ExpenseRefresh"),
                    object: .none
                )
                return .success(())
            } catch {
                return .failure(.updateFailure)
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    public func resetExpenses() -> Result<Void, DataControllerError> {
        switch validateUser() {
        case let .success(userId):
            do {
                let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
                request.predicate = NSPredicate(format: "userID == %@", userId)
                let results = try expenseModelContext.fetch(request)
                for expense in results {
                    expenseModelContext.delete(expense)
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
        case let .failure(error):
            return .failure(error)
        }
    }

    public func fetchExpenses() -> Result<[ExpenseViewModel], DataControllerError> {
        switch validateUser() {
        case let .success(userId):
            do {
                let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
                request.predicate = NSPredicate(format: "userID == %@", userId)
                let result = try expenseModelContext.fetch(request)
                let expenses = result.map { ExpenseViewModel(from: $0) }
                return .success(expenses)
            } catch {
                return .failure(.fetchFailure)
            }
        case let .failure(error):
            return .failure(error)
        }
    }

    // MARK: - START DAY (User-Specific)
    func fetchTargetSetDate() -> Result<Date?, DataControllerError> {
        switch validateUser() {
        case let .success(userId):
            guard let savedDate = UserDefaults.standard.string(forKey: UserDefaultsKeys.startDate(for: userId)) else {
                return .success(nil)
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: savedDate) else {
                return .failure(.dateParsingFailure)
            }
            return .success(date)
        case let .failure(error):
            return .failure(error)
        }
    }

    func saveTargetSetDate(_ date: Date) -> Result<Void, DataControllerError> {
        switch validateUser() {
        case let .success(userId):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)
            UserDefaults.standard.set(dateString, forKey: UserDefaultsKeys.startDate(for: userId))
            return .success(())
        case let .failure(error):
            return .failure(error)
        }
    }
    
    // MARK: - User Data Management
    public func deleteAllUserData() -> Result<Void, DataControllerError> {
        switch validateUser() {
        case let .success(userId):
            // Delete Core Data entries
            let _ = resetExpenses()
            
            // Delete UserDefaults entries
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.timeFrame(for: userId))
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.targetSpending(for: userId))
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.startDate(for: userId))
            
            return .success(())
        case let .failure(error):
            return .failure(error)
        }
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
}
