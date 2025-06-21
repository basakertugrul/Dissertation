import SwiftUI
import AuthenticationServices
import LocalAuthentication

// MARK: - Sign In Errors
enum SignInError: Error, LocalizedError {
    case appleSignInCanceled
    case appleSignInFailed
    case faceIDAuthenticationFailed
    case faceIDCanceled
    case userDataSaveFailure
    case credentialStateCheckFailed
    case biometryNotEnrolled
    case biometryLockout
    case unknownError(String)

    var errorDescription: String {
        switch self {
        case .appleSignInCanceled:
            return "Sign in was canceled. Please try again."
        case .appleSignInFailed:
            return "Apple Sign In failed. Please check your connection and try again."
        case .faceIDAuthenticationFailed:
            return "Face ID authentication failed. Please try again."
        case .faceIDCanceled:
            return "Face ID authentication was canceled."
        case .userDataSaveFailure:
            return "Failed to save your account information. Please try signing in again."
        case .credentialStateCheckFailed:
            return "Unable to verify your Apple ID status. Please try again."
        case .biometryNotEnrolled:
            return "Face ID is not set up. Please set it up in Settings."
        case .biometryLockout:
            return "Face ID is temporarily locked. Please try again later."
        case .unknownError:
            return "An unexpected error occurred"
        }
    }
}

struct SignInAppleIdButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton()
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

final class SignInWithAppleCoordinator: NSObject {
    private var appleSignInCompletion: ((Result<ASAuthorization, SignInError>) -> Void)?
    private var faceIDCompletion: ((Bool) -> Void)?

    func getAppleRequest(
        completion: @escaping (Result<ASAuthorization, SignInError>) -> Void
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
    func requestFaceIDPermission(completion: @escaping (Result<Bool, SignInError>) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Enable Face ID to quickly sign in to FundBud"
        ) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    if let laError = error as? LAError {
                        switch laError.code {
                        case .userCancel:
                            completion(.success(false))
                        case .biometryNotEnrolled:
                            completion(.failure(.biometryNotEnrolled))
                        case .biometryLockout:
                            completion(.failure(.biometryLockout))
                        default:
                            completion(.failure(.faceIDAuthenticationFailed))
                        }
                    } else {
                        completion(.failure(.faceIDAuthenticationFailed))
                    }
                } else if success {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            }
        }
    }
    
    /// Authenticate with Face ID for returning users
    func authenticateWithFaceID(completion: @escaping (Result<Void, SignInError>) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Password"
        
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: "Sign in to FundBud with Face ID"
        ) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    if let laError = error as? LAError {
                        switch laError.code {
                        case .userCancel:
                            completion(.failure(.faceIDCanceled))
                        case .authenticationFailed:
                            completion(.failure(.faceIDAuthenticationFailed))
                        case .biometryLockout:
                            completion(.failure(.biometryLockout))
                        default:
                            completion(.failure(.faceIDAuthenticationFailed))
                        }
                    } else {
                        completion(.failure(.faceIDAuthenticationFailed))
                    }
                } else if success {
                    completion(.success(()))
                } else {
                    completion(.failure(.faceIDAuthenticationFailed))
                }
            }
        }
    }
    
    private func setUserInfo(
        for userID: String,
        fullName: String?,
        email: String?,
        askForFaceID: Bool = true,
        completion: @escaping (Result<Void, SignInError>) -> Void
    ) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { credentialState, error in
            if error != nil {
                completion(.failure(.credentialStateCheckFailed))
                return
            }
            
            var authState: String
            switch credentialState {
            case .authorized:
                authState = "authorized"
            case .revoked:
                authState = "revoked"
            case .transferred:
                authState = "transferred"
            case .notFound:
                authState = "not found"
            @unknown default:
                authState = "unknown"
            }
            
            // Ask for Face ID permission if it's a new signup
            if askForFaceID, self.isFaceIDAvailable() {
                DispatchQueue.main.async {
                    self.requestFaceIDPermission { result in
                        switch result {
                        case .success(let faceIDEnabled):
                            self.saveUser(
                                fullName: fullName,
                                email: email,
                                authState: authState,
                                hasFaceIDEnabled: faceIDEnabled,
                                completion: completion
                            )
                        case .failure:
                            self.saveUser(
                                fullName: fullName,
                                email: email,
                                authState: authState,
                                hasFaceIDEnabled: false,
                                completion: completion
                            )
                        }
                    }
                }
            } else {
                // No Face ID available or not asking for it
                self.saveUser(
                    fullName: fullName,
                    email: email,
                    authState: authState,
                    hasFaceIDEnabled: false,
                    completion: completion
                )
            }
        }
    }

    private func saveUser(
        fullName: String?,
        email: String?,
        authState: String,
        hasFaceIDEnabled: Bool,
        completion: @escaping (Result<Void, SignInError>) -> Void
    ) {
        let user = User(
            fullName: fullName ?? "",
            email: email ?? "",
            authState: authState,
            hasFaceIDEnabled: hasFaceIDEnabled
        )
        do {
            let userEncoded = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userEncoded, forKey: "user")
            completion(.success(()))
            NotificationCenter.default.post(
                name: Notification.Name("LoggedIn"),
                object: nil
            )
        } catch {
            completion(.failure(.userDataSaveFailure))
        }
    }
}

extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let givenName = credential.fullName?.givenName ?? ""
            let familyName = credential.fullName?.familyName ?? ""
            let fullName = (givenName + " " + familyName).trimmingCharacters(in: .whitespacesAndNewlines)
            setUserInfo(
                for: credential.user,
                fullName: fullName.isEmpty ? nil : fullName,
                email: credential.email
            ) { result in
                switch result {
                case .success:
                    self.appleSignInCompletion?(.success(authorization))
                case .failure(let error):
                    self.appleSignInCompletion?(.failure(error))
                }
                self.appleSignInCompletion = nil
            }
        } else {
            appleSignInCompletion?(.failure(.appleSignInFailed))
            appleSignInCompletion = nil
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                appleSignInCompletion?(.failure(.appleSignInCanceled))
            case .failed:
                appleSignInCompletion?(.failure(.appleSignInFailed))
            case .invalidResponse:
                appleSignInCompletion?(.failure(.appleSignInFailed))
            case .notHandled:
                appleSignInCompletion?(.failure(.appleSignInFailed))
            default: break
            }
        }
        appleSignInCompletion = nil
    }
}
