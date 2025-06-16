import SwiftUI

struct SignInView: View {
    @State private var hasDailyLimit: Bool = false
    @Binding var isLoading: Bool
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        if let user = appState.user {
            LoginScreenView(
                loginStyle: .returningUser(user),
                actions: appState,
                isLoading: $isLoading
            )
        } else {
            LoginScreenView(
                loginStyle: .newUser,
                actions: appState,
                isLoading: $isLoading
            )
            .onAppear {
                self.appState.getUserInfo()
                DispatchQueue.main.async {
                    appState.authenticateUserOnLaunch()
                }
            }
            .shadow(color: Color.secondary.opacity(0.5), radius: 10, y: 8)
        }
    }
}
