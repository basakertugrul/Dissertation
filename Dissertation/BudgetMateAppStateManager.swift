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
    @Published var user: User?
    @Published var hasLoggedIn: Bool = false

    /// UI variables
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
        totalBudgetAccumulated - totalExpenses
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
        }
    }

    func refreshExpenses() {
        switch dataController.fetchExpenses() {
        case let .success(expenses):
            expenseViewModels = expenses
        case let .failure(comingError):
            error = comingError
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
        }
    }

    /// Update start date and save to storage
    func updateStartDate(_ newDate: Date) {
        startDate = newDate
        switch dataController.saveTargetSetDate(newDate) {
        case .success: break
        case let .failure(comingError):
            error = comingError
        }
    }
    
    func resetData() {
        let _ = dataController.resetTimeFrame()
        let _ = dataController.resetTargetSpending()
        let _ = dataController.resetExpenses()
        dailyBalance = .none
        user = nil
    }
}

extension AppStateManager {
    func getUserInfo() {
        if let userData = UserDefaults.standard.data(forKey: "user"),
           let userDecoded = try? JSONDecoder().decode(User.self, from: userData) {
            user = userDecoded
        }
    }

    func authenticateUserOnLaunch() {
        guard let user = user, user.hasFaceIDEnabled else { return }
        enableLoadingView()
        signInWithApple.authenticateWithFaceID { result in
            self.disableLoadingView()
            switch result {
            case .success: self.logIn()
            case let .failure(error): self.signInError = error
            }
        }
    }
    
    private func logIn() {
        DispatchQueue.main.async() {
            self.hasLoggedIn = true
        }
    }

    private func disableLoadingView() {
        withAnimation {
            isLoading = false
        }
    }

    private func enableLoadingView() {
        withAnimation {
            isLoading = true
        }
    }
}

extension AppStateManager: LoginActions {
    func handleFaceIDSignIn() {
        enableLoadingView()
        signInWithApple.authenticateWithFaceID { result in
            self.disableLoadingView()
            switch result {
            case .success: self.logIn()
            case let .failure(error): self.signInError = error
            }
        }
    }

    func handleAppleSignIn() {
        enableLoadingView()
        signInWithApple.getAppleRequest { result in
            self.disableLoadingView()
            switch result {
            case .success: self.logIn()
            case let .failure(error): self.signInError = error
            }
        }
    }

    func handleTermsAndPrivacyTap() {
        print("Opening terms of service...")
    }

    func changeUser() {}
}

extension AppStateManager: ProfileActionsDelegate {
    func editBudget(currentAmount: Double) {
        switch dataController.saveTargetSpending(to: currentAmount) {
        case .success:
            refreshDailyBalance()
        case let .failure(comingError):
            error = comingError
        }
    }
    
    func signOut() {
        self.hasLoggedIn = false
        self.isProfileScreenOpen = false
    }

    func manageNotifications() {
        print("Manage notifications")
    }

    func exportExpenseData() {
        print("Export expense data")
    }

    func managePrivacySettings() {
        print("Manage privacy settings")
    }

    func sendFeedback() {
        print("Send feedback")
    }

    func rateApp() {
        print("Rate app")
    }

    func showLegalInfo() {
        print("Show legal info")
    }
}
