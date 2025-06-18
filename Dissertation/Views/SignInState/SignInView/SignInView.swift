import SwiftUI

struct SignInView: View {
    @State private var hasDailyLimit: Bool = false
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        if let user = appState.user {
            LoginScreenView(
                loginStyle: .returningUser(user),
                actions: appState,
                isLoading: $appState.isLoading
            )
        } else {
            LoginScreenView(
                loginStyle: .newUser(.none),
                actions: appState,
                isLoading: $appState.isLoading
            )
            .onAppear {
                DispatchQueue.main.async {
                    appState.authenticateUserOnLaunch()
                }
            }
            .shadow(color: .customRichBlack.opacity(0.5), radius: 10, y: 8)
        }
    }
}
