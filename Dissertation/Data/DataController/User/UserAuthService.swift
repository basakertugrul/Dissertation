import Foundation

// MARK: - User Authentication Service
class UserAuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isFirstTimeUser: Bool = true

    private let userDefaultsKey = "current_user_data"
    private let firstTimeKey = "has_completed_onboarding"

    static let shared = UserAuthService()

    private init() {
        checkFirstTimeUser()
        loadCurrentUser()
    }

    // MARK: - First Time User Setup
    private func checkFirstTimeUser() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: firstTimeKey)
        isFirstTimeUser = !hasCompletedOnboarding
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: firstTimeKey)
        isFirstTimeUser = false
    }

    // MARK: - Unified Sign In Function
    func signIn(email: String? = nil, displayName: String? = nil) {
        let user = User(email: email, displayName: displayName)
        currentUser = user
        isAuthenticated = true
        saveCurrentUser()

        NotificationCenter.default.post(
            name: Notification.Name("LoggedIn"),
            object: nil
        )
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
    
    private func saveCurrentUser() {
        guard let user = currentUser else { return }
        
        let userData: [String: Any] = [
            "id": user.id.uuidString,
            "email": user.email ?? "",
            "displayName": user.displayName ?? "",
            "createdAt": user.createdAt.timeIntervalSince1970
        ]
        
        UserDefaults.standard.set(userData, forKey: userDefaultsKey)
    }

    func loadCurrentUser() {
        guard let userData = UserDefaults.standard.dictionary(forKey: userDefaultsKey),
              let idString = userData["id"] as? String,
              let id = UUID(uuidString: idString),
              let createdAtInterval = userData["createdAt"] as? TimeInterval else {
            return
        }
        
        let email = (userData["email"] as? String)?.isEmpty == false ? userData["email"] as? String : nil
        let displayName = (userData["displayName"] as? String)?.isEmpty == false ? userData["displayName"] as? String : nil
        
        currentUser = User(id: id, email: email, displayName: displayName, createdAt: Date(timeIntervalSince1970: createdAtInterval))
        isAuthenticated = true
    }
}
