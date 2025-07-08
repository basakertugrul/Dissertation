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
            return NSLocalizedString("signin_canceled", comment: "")
        case .appleSignInFailed:
            return NSLocalizedString("apple_signin_failed", comment: "")
        case .faceIDAuthenticationFailed:
            return NSLocalizedString("faceid_auth_failed", comment: "")
        case .faceIDCanceled:
            return NSLocalizedString("faceid_canceled", comment: "")
        case .userDataSaveFailure:
            return NSLocalizedString("user_data_save_failure", comment: "")
        case .credentialStateCheckFailed:
            return NSLocalizedString("credential_state_check_failed", comment: "")
        case .biometryNotEnrolled:
            return NSLocalizedString("biometry_not_enrolled", comment: "")
        case .biometryLockout:
            return NSLocalizedString("biometry_lockout", comment: "")
        case .unknownError:
            return NSLocalizedString("unknown_error", comment: "")
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
        context.localizedFallbackTitle = NSLocalizedString("use_passcode", comment: "")

        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: NSLocalizedString("enable_faceid_reason", comment: "")
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
        context.localizedFallbackTitle = NSLocalizedString("use_password", comment: "")
        
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: NSLocalizedString("signin_faceid_reason", comment: "")
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
            
            var authState: AuthState
            switch credentialState {
            case .authorized:
                authState = .authorized
            case .revoked:
                authState = .revoked
            case .transferred:
                authState = .transferred
            case .notFound:
                authState = .notFound
            @unknown default:
                authState = .notFound
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
        authState: AuthState,
        hasFaceIDEnabled: Bool,
        completion: @escaping (Result<Void, SignInError>) -> Void
    ) {
        UserAuthService.shared.signIn(
            email: email,
            displayName: fullName
        )
        completion(.success(()))
        return
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
                fullName: fullName,
                email: credential.email
            ) { result in
                switch result {
                case .success:
                    self.appleSignInCompletion?(.success(authorization))
                case let .failure(error):
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
