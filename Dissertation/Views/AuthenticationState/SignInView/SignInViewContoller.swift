import SwiftUI
import AuthenticationServices

struct SignInAppleIdButton: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton ()
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

final class SignInWithAppleCoordinator: NSObject {
    func getAppleRequest () {
        let appleIDProvider = ASAuthorizationAppleIDProvider ()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.performRequests()
    }
    
    private func setUserInfo(for userID: String, fullName: String?, email: String?) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { credentialState, error in
            var authState: String?
            switch credentialState {
            case .authorized: authState = "authorized"
            case .revoked: authState = "revoked"
            case .transferred: authState = "transferred"
            case .notFound: authState = "not found"
            @unknown default: fatalError()
            }
            
            let user = User(fullName: fullName ?? "No name", email: email ?? "No email", authState: authState ?? "unknown", hasFaceIDEnabled: true)
            //TODO: Add asking for faceid too
            if let userEncoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userEncoded, forKey: "user")
            }
        }
    }
}

extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let crediential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let fullName = ((crediential.fullName?.givenName ?? "") + " " + (crediential.fullName?.familyName ?? ""))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            setUserInfo(for: crediential.user, fullName: fullName, email: crediential.email)
            
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("SIGN IN ERROR: \(error)")
    }
}
