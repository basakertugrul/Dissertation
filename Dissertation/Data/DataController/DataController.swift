import CoreData

struct DataController {
    public static let shared = DataController()
    let expenseModelContainer: NSPersistentContainer
    var expenseModelContext: NSManagedObjectContext {
        expenseModelContainer.viewContext
    }

    var targetSpendingModelContainer: NSPersistentContainer
    var targetSpendingModelContext: NSManagedObjectContext {
        targetSpendingModelContainer.viewContext
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
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }

    public func deleteExpense(of expense: ExpenseViewModel) {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)

        do {
            let results = try expenseModelContext.fetch(request)
            for expense in results {
                expenseModelContext.delete(expense)
            }
            try expenseModelContext.save()
            print("🗑️ Expense deleted")
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
                name: Notification.Name("ExpenseUpdated"),
                object: nil
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
        } catch {
            print("❌: \(error)")
        }
    }

    public func fetchExpenses() -> [ExpenseViewModel] {
        let request: NSFetchRequest<ExpenseModel> = ExpenseModel.fetchRequest()

        do {
            let result = try expenseModelContext.fetch(request)
            return result.map {
                ExpenseViewModel.createWithPound(
                    name: $0.name ?? "",
                    date: $0.date ?? .now,
                    amount: $0.amount,
                    createDate: $0.createDate ?? .now
                )
            }
        } catch {
            print("❌ Failed to fetch expenses: \(error)")
            return []
        }
    }

    public func saveTargetSpending(to data: Double) {
        let newTargetSpending = TargetSpendingModel(context: targetSpendingModelContext)
        newTargetSpending.amount = data
        newTargetSpending.currencyCode = "GBP"

        do {
            try targetSpendingModelContext.save()
            NotificationCenter.default.post(
                name: Notification.Name("TargetSpendingMoneyUpdated"),
                object: nil
            )
            print("✅ Target Spending saved")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }

    public func resetTargetSpending() {
        let request: NSFetchRequest<TargetSpendingModel> = TargetSpendingModel.fetchRequest()

        do {
            let results = try targetSpendingModelContext.fetch(request)
            for targetSpending in results {
                targetSpendingModelContext.delete(targetSpending)
            }
            try targetSpendingModelContext.save()
            NotificationCenter.default.post(
                name: Notification.Name("TargetSpendingMoneyUpdated"),
                object: nil
            )
            print("🗑️ Target spending deleted")
        } catch {
            print("❌ Failed to delete target spending: \(error)")
        }
    }

    public func fetchTargetSpendingMoney() -> Double? {
        let request: NSFetchRequest<TargetSpendingModel> = TargetSpendingModel.fetchRequest()
        request.fetchLimit = 1

        do {
            if let result = try targetSpendingModelContext.fetch(request)
                .first?
                .amount {
                return result
            }
        } catch {
            print("❌ Failed to fetch expenses: \(error)")
        }
        return nil
    }
}

//TODO: Aylık görme - haftalık görme - yıllık görme olsun
