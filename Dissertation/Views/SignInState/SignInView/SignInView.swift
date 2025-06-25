import SwiftUI

struct SignInView: View {
    @State private var hasDailyLimit: Bool = false
    
    var body: some View {
        if let user = UserAuthService.shared.currentUser {
            LoginScreenView(
                loginStyle: .returningUser(user)
            )
        } else {
            LoginScreenView(
                loginStyle: .newUser(.none)
            )
        }
    }
}
