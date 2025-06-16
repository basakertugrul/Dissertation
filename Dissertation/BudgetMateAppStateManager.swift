import SwiftUI

// MARK: - App State Manager
final class AppStateManager: ObservableObject {
    public static let shared = AppStateManager()
 
    private init() {
        self.expenseViewModels = []
        self.startDate = .now
    }

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

    /// Loading variable
    @Published var isLoading: Bool = false

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

    func loadInitialData() {
        refreshDailyBalance()
        refreshExpenses()
        loadOrSetStartDate()
    }

    func refreshDailyBalance() {
        dailyBalance = dataController.fetchTargetSpendingMoney()
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

    func handleEmailPasswordSignIn(email: String, password: String) {
        print("handleEmailPasswordSignIn...")
    }

    func handleTermsTap() {
        print("Opening terms of service...")
    }

    func handlePrivacyTap() {
        print("Opening privacy policy...")
    }
}
