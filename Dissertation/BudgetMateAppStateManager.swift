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
    @Published var hasLoggedIn: Bool = false {
        didSet {
            print(hasLoggedIn)
        }
    }

    /// UI variables
    @Published var isLoading: Bool = false
    @Published var isProfileScreenOpen: Bool = false
    @State var hasAddedExpense: Bool = false
    @State var hasUpdatedExpense: Bool = false
    @State var hasDeletedExpense: Bool = false
    @State var error: DataControllerError? = .none
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
        signInWithApple.authenticateWithFaceID { result in // TODO: Show an error if error occurs
            self.disableLoadingView()
            switch result {
            case .success: self.logIn()
            case .failure: break
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
        signInWithApple.authenticateWithFaceID { result in // TODO: Show an error if error occurs
            self.disableLoadingView()
            switch result {
            case .success: self.logIn()
            case .failure: break
            }
        }
    }

    func handleAppleSignIn() {
        enableLoadingView()
        signInWithApple.getAppleRequest { result in // TODO: Show an error if error occurs
            self.disableLoadingView()
            switch result {
            case .success: self.logIn()
            case .failure: break
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
        dataController.saveTargetSpending(to: currentAmount)
        refreshDailyBalance()
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
