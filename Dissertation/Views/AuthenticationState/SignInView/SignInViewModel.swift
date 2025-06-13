import Foundation

final class SignInViewModel: ObservableObject {
    private lazy var signInWithApple = SignInWithAppleCoordinator()
    @Published var user: User?
    @Published var error: String?

    func getRequest() {
        signInWithApple.getAppleRequest()
    }

    func getUserInfo() {
        if let userData = UserDefaults.standard.data(forKey: "user"),
           let userDecoded = try? JSONDecoder().decode(User.self, from: userData) {
            user = userDecoded
        }
    }
}

extension SignInViewModel: LoginActions {
    func handleAppleSignIn() {
        print("Initiating Apple Sign In...")
    }
    
    func handleGoogleSignIn() {
        print("Initiating Google Sign In...")
    }

    func handleFaceIDSignIn() {
        print("Initiating Face ID authentication...")
    }
    
    func handleAlternativeSignIn() {
        print("Showing alternative sign in methods...")
    }
    
    func handleTermsTap() {
        print("Opening terms of service...")
    }
    
    func handlePrivacyTap() {
        print("Opening privacy policy...")
    }
}
