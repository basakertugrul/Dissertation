import SwiftUI
import AuthenticationServices
import LocalAuthentication

struct SignInAppleIdButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton()
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

final class SignInWithAppleCoordinator: NSObject {
    private var appleSignInCompletion: ((Result<ASAuthorization, Error>) -> Void)?
    private var faceIDCompletion: ((Bool) -> Void)?

    func getAppleRequest(
        completion: @escaping (Result<ASAuthorization, Error>) -> Void
    ) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        
        appleSignInCompletion = completion
        
        authController.performRequests()
    }
    
    // MARK: - Face ID Methods
    
    /// Check if Face ID is available on device
    func isFaceIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) &&
               context.biometryType == .faceID
    }
    
    /// Request Face ID permission and setup
    func requestFaceIDPermission(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Enable Face ID to quickly sign in to BudgetMate"
        ) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    /// Authenticate with Face ID for returning users
    func authenticateWithFaceID(completion: @escaping (Result<Void, Error>) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Password"
        
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Sign in to BudgetMate with Face ID"
        ) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Face ID authentication failed: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if success {
                    completion(.success(()))
                }
               
            }
        }
    }
    
    private func setUserInfo(
        for userID: String,
        fullName: String?,
        email: String?,
        askForFaceID: Bool = true
    ) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { credentialState, error in
            var authState: String?
            switch credentialState {
            case .authorized: authState = "authorized"
            case .revoked: authState = "revoked"
            case .transferred: authState = "transferred"
            case .notFound: authState = "not found"
            @unknown default: fatalError()
            }
            
            // Ask for Face ID permission if it's a new signup
            if askForFaceID && self.isFaceIDAvailable() {
                DispatchQueue.main.async {
                    self.requestFaceIDPermission { faceIDEnabled in
                        let user = User(
                            fullName: fullName ?? "No name",
                            email: email ?? "No email",
                            authState: authState ?? "unknown",
                            hasFaceIDEnabled: faceIDEnabled
                        )
                        
                        if let userEncoded = try? JSONEncoder().encode(user) {
                            UserDefaults.standard.set(userEncoded, forKey: "user")
                        }
                    }
                }
            } else {
                // No Face ID available or not asking for it
                let user = User(
                    fullName: fullName ?? "No name",
                    email: email ?? "No email",
                    authState: authState ?? "unknown",
                    hasFaceIDEnabled: false
                )
                
                if let userEncoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(userEncoded, forKey: "user")
                }
            }
        }
    }
}

extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let fullName = ((credential.fullName?.givenName ?? "") + " " + (credential.fullName?.familyName ?? ""))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            setUserInfo(for: credential.user, fullName: fullName, email: credential.email)

            appleSignInCompletion?(.success(authorization))
            appleSignInCompletion = nil
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        appleSignInCompletion?(.failure(error))
        appleSignInCompletion = nil
    }
}
