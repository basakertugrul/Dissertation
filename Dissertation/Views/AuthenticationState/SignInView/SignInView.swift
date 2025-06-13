import SwiftUI

struct SignInView: View {
    @ObservedObject private var viewModel = SignInViewModel()
    @State private var hasDailyLimit: Bool = false

    @Binding var isLoading: Bool
    
    var body: some View {
        if let user = viewModel.user {
            LoginScreenView(
                loginStyle: .returningUser(user),
                actions: viewModel,
                isLoading: $isLoading
            )
        } else {
            LoginScreenView(
                loginStyle: .newUser,
                actions: viewModel,
                isLoading: $isLoading
            )
            .onAppear {
                self.viewModel.getUserInfo()
            }
            .shadow(color: Color.secondary.opacity(0.5), radius: 10, y: 8)
        }
    }
}
