import Foundation

// MARK: - User Authentication Service
class UserAuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isFirstTimeUser: Bool = false
    
    private let userDefaultsKey = "current_user_data"
    private let firstTimeKey = "is_first_time_user"
    
    static let shared = UserAuthService()
    
    private init() {
        checkFirstTimeUser()
        loadCurrentUser()
    }
    
    // MARK: - First Time User Setup
    private func checkFirstTimeUser() {
        isFirstTimeUser = !UserDefaults.standard.bool(forKey: firstTimeKey)
    }
    
    private func completeFirstTimeSetup() {
        UserDefaults.standard.set(true, forKey: firstTimeKey)
        isFirstTimeUser = false
    }
    
    // MARK: - Unified Sign In Function
    func signIn(email: String? = nil, displayName: String? = nil) {
        let user = User(email: email, displayName: displayName)
        currentUser = user
        isAuthenticated = true
        saveCurrentUser()
        
        if isFirstTimeUser {
            completeFirstTimeSetup()
            NotificationCenter.default.post(
                name: Notification.Name("FirstTimeSignIn"),
                object: nil
            )
        } else {
            NotificationCenter.default.post(
                name: Notification.Name("LoggedIn"),
                object: nil
            )
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
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
    
    private func loadCurrentUser() {
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
