import SwiftUI
import AuthenticationServices

// MARK: - App State Manager
final class AppStateManager: ObservableObject {
    public static let shared = AppStateManager()
    private init() {
        self.expenseViewModels = []
        self.startDate = .now
        setupUserAuthObservation()
    }

    /// App Data Variables
    @Published var dailyBalance: Double?
    @Published var expenseViewModels: [ExpenseViewModel]
    @Published var startDate: Date
    private let dataController = DataController.shared
    
    /// UserAuthService integration
    private let userAuthService = UserAuthService.shared
    private lazy var signInWithApple = SignInWithAppleCoordinator()

    /// UI variables
    @Published var willOpenCameraView: Bool = false
    @Published var isLoading: Bool = false
    @Published var isProfileScreenOpen: Bool = false
    @Published var hasAddedExpense: Bool = false
    @Published var hasUpdatedExpense: Bool = false
    @Published var hasDeletedExpense: Bool = false
    @Published var hasSavedDailyLimit: Bool = false
    @Published var error: DataControllerError? = .none
    @Published var signInError: SignInError? = .none
    
    // MARK: - User Properties (via UserAuthService)
    var user: User? {
        userAuthService.currentUser
    }
    
    var hasLoggedIn: Bool {
        userAuthService.isAuthenticated
    }
    
    var isFirstTimeUser: Bool {
        userAuthService.isFirstTimeUser
    }
    
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
    
    // MARK: - UserAuthService Integration
    private func setupUserAuthObservation() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFirstTimeSignIn),
            name: Notification.Name("FirstTimeSignIn"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserSignIn),
            name: Notification.Name("LoggedIn"),
            object: nil
        )
    }
    
    @objc private func handleFirstTimeSignIn() {
        DispatchQueue.main.async {
            /// Handle first-time user setup if needed
            self.loadInitialData()
        }
    }
    
    @objc private func handleUserSignIn() {
        DispatchQueue.main.async {
            /// Refresh data when user signs in
            self.loadInitialData()
        }
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
        userAuthService.signOut()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AppStateManager: LoginActions {
    func handleFaceIDSignIn() {
        enableLoadingView()
        signInWithApple.authenticateWithFaceID { result in
            self.disableLoadingView()
            switch result {
            case .success:
                /// UserAuthService will handle the sign-in state
                break
            case let .failure(error):
                self.signInError = error
            }
        }
    }

    func handleAppleSignIn() {
        enableLoadingView()
        signInWithApple.getAppleRequest { result in
            self.disableLoadingView()
            switch result {
            case let .success(authorization):
                /// Extract user data from ASAuthorization
                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    let email = appleIDCredential.email
                    let fullName = appleIDCredential.fullName
                    let displayName = [fullName?.givenName, fullName?.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    /// Sign in through UserAuthService
                    self.userAuthService.signIn(
                        email: email,
                        displayName: displayName.isEmpty ? nil : displayName
                    )
                }
            case let .failure(error):
                self.signInError = error
            }
        }
    }

    func handleTermsAndPrivacyTap() {}

    func changeUser() {
        userAuthService.signOut()
    }
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
        userAuthService.signOut()
        self.isProfileScreenOpen = false
    }

    func manageNotifications() {} /// TODO: ADD coming

    func exportExpenseData() {
        enableLoadingView()
        generateExpensePDF { [weak self] pdfData in
            guard let self = self, let pdfData = pdfData else {
                return
            }

            DispatchQueue.main.async {
                self.sharePDF(pdfData: pdfData)
            }
        }
    }
}
