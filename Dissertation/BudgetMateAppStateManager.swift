import SwiftUI

// MARK: - App State Manager
final class AppStateManager: ObservableObject {
    public static let shared = AppStateManager()
    private init() {
        self.expenseViewModels = []
        self.startDate = .now
    }

    /// App Data Variables
    @Published var dailyBalance: Double?
    @Published var expenseViewModels: [ExpenseViewModel]
    @Published var startDate: Date
    private let dataController = DataController.shared
    
    /// SignIn Variables
    private lazy var signInWithApple = SignInWithAppleCoordinator()
    @Published var hasLoggedIn: Bool = false

    /// UI variables
    @Published var willOpenCameraView: Bool = false
    @Published var willOpenVoiceRecording: Bool = false
    @Published var isLoading: Bool = false
    @Published var isProfileScreenOpen: Bool = false
    @Published var hasAddedExpense: Bool = false
    @Published var hasUpdatedExpense: Bool = false
    @Published var hasDeletedExpense: Bool = false
    @Published var hasSavedDailyLimit: Bool = false
    @Published var error: DataControllerError? = .none
    @Published var signInError: SignInError? = .none
    
    /// Days since the app start date was set
    var daysSinceStart: Int {
        let calendar = Calendar.current
        return (calendar.dateComponents([.day],
                                     from: calendar.startOfDay(for: startDate),
                                     to: calendar.startOfDay(for: Date())).day ?? 0) + 1
    }
    /// Total budget accumulated since start date
    var totalBudgetAccumulated: Double {
        (dailyBalance ?? .zero) * Double(daysSinceStart)
    }
    var totalExpenses: Double {
        expenseViewModels.reduce(0) { $0 + $1.amount }
    }
    /// Improved balance calculation using start date
    var calculatedBalance: Double {
        let difference = Decimal(totalBudgetAccumulated) - Decimal(totalExpenses)
        let rounded = NSDecimalNumber(decimal: difference).doubleValue
        return rounded
    }
    /// Average daily spending since start date
    var formattedAverageDaily: Double {
        guard daysSinceStart > 0 else { return .zero }
        let averageDaily = totalExpenses / Double(daysSinceStart)
        return averageDaily
    }
    
    // MARK: - Methods
    func loadInitialData() {
        refreshDailyBalance()
        refreshExpenses()
        loadOrSetStartDate()
    }

    func refreshDailyBalance() {
        switch dataController.fetchTargetSpendingMoney() {
        case let .success(amount):
            dailyBalance = amount
        case let .failure(comingError):
            error = comingError
            HapticManager.shared.trigger(.error)
        }
    }

    func refreshExpenses() {
        switch dataController.fetchExpenses() {
        case let .success(expenses):
            expenseViewModels = expenses
        case let .failure(comingError):
            error = comingError
            HapticManager.shared.trigger(.error)
        }
    }
    
    /// Load existing start date or set new one if it doesn't exist
    private func loadOrSetStartDate() {
        switch dataController.fetchTargetSetDate() {
        case let .success(date):
            if let date = date {
                startDate = date
            } else {
                startDate = Date()
                let _ = dataController.saveTargetSetDate(startDate)
            }
        case let .failure(comingError):
            error = comingError
            HapticManager.shared.trigger(.error)
        }
    }

    /// Update start date and save to storage
    func updateStartDate(_ newDate: Date) {
        startDate = newDate
        switch dataController.saveTargetSetDate(newDate) {
        case .success:
            HapticManager.shared.trigger(.success)
        case let .failure(comingError):
            error = comingError
            HapticManager.shared.trigger(.error)
        }
    }
    
    func resetData() {
        let _ = dataController.resetTimeFrame()
        let _ = dataController.resetTargetSpending()
        let _ = dataController.resetExpenses()
        dailyBalance = .none
        UserAuthService.shared.signOut()
        HapticManager.shared.trigger(.warning)
    }
}

extension AppStateManager {
    func getUserInfo() {
        UserAuthService.shared.loadCurrentUser()
    }

    func authenticateUserOnLaunch() {
        guard UserAuthService.shared.currentUser != nil else { return }
        enableLoadingView()
        signInWithApple.authenticateWithFaceID { result in
            self.disableLoadingView()
            switch result {
            case .success:
                self.logIn()
                HapticManager.shared.trigger(.login)
            case let .failure(error):
                self.signInError = error
                HapticManager.shared.trigger(.error)
            }
        }
    }
    
    private func logIn() {
        DispatchQueue.main.async() {
            self.hasLoggedIn = true
        }
    }

    func enableLoadingView() {
        DispatchQueue.main.async {
            withAnimation {
                self.isLoading = true
            }
        }
    }

    func disableLoadingView() {
        DispatchQueue.main.async {
            withAnimation {
                self.isLoading = false
            }
        }
    }
}

extension AppStateManager: LoginActions {
    func handleFaceIDSignIn() {
        enableLoadingView()
        signInWithApple.authenticateWithFaceID { result in
            self.disableLoadingView()
            switch result {
            case .success:
                self.logIn()
                HapticManager.shared.trigger(.login)
            case let .failure(error):
                self.signInError = error
                HapticManager.shared.trigger(.error)
            }
        }
    }

    func handleAppleSignIn() {
        enableLoadingView()
        signInWithApple.getAppleRequest { result in
            self.disableLoadingView()
            switch result {
            case .success:
                self.logIn()
                HapticManager.shared.trigger(.login)
            case let .failure(error):
                self.signInError = error
                HapticManager.shared.trigger(.error)
            }
        }
    }
}

extension AppStateManager: ProfileActionsDelegate {
    func editBudget(currentAmount: Double) {
        switch dataController.saveTargetSpending(to: currentAmount) {
        case .success:
            refreshDailyBalance()
            HapticManager.shared.trigger(.success)
        case let .failure(comingError):
            error = comingError
            HapticManager.shared.trigger(.error)
        }
    }

    func signOut() {
        self.hasLoggedIn = false
        self.isProfileScreenOpen = false
        HapticManager.shared.trigger(.logout)
    }

    func manageNotifications() {
        HapticManager.shared.trigger(.navigation)
    }

    func exportExpenseData() {
        enableLoadingView()
        HapticManager.shared.trigger(.buttonTap)
        generateExpensePDF { [weak self] pdfData in
            guard let self = self, let pdfData = pdfData else {
                HapticManager.shared.trigger(.error)
                return
            }

            DispatchQueue.main.async {
                self.sharePDF(pdfData: pdfData)
                HapticManager.shared.trigger(.success)
            }
        }
    }

    func deleteAccount() {
        HapticManager.shared.trigger(.warning)
        enableLoadingView()
        // Perform account deletion on background queue to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // Delete all user data from Core Data/storage
            let _ = self.dataController.resetTimeFrame()
            let _ = self.dataController.resetTargetSpending()
            let _ = self.dataController.resetExpenses()

            // Clear any cached user preferences or settings
            // You might want to add additional cleanup here based on what other data you store
            UserDefaults.standard.removeObject(forKey: "user_preferences")
            UserDefaults.standard.removeObject(forKey: "app_settings")
            UserDefaults.standard.synchronize()
            
            // Sign out the user from authentication services
            UserAuthService.shared.signOut()
            
            // Update UI on main thread
            DispatchQueue.main.async {
                // Reset all app state variables
                self.dailyBalance = nil
                self.expenseViewModels = []
                self.startDate = .now
                self.hasLoggedIn = false
                self.isProfileScreenOpen = false
                self.hasAddedExpense = false
                self.hasUpdatedExpense = false
                self.hasDeletedExpense = false
                self.hasSavedDailyLimit = false
                self.error = nil
                self.signInError = nil

                self.disableLoadingView()
                HapticManager.shared.trigger(.success)
            }
        }
    }
}
