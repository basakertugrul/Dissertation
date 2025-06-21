import SwiftUI

// MARK: - Login Style Enum
enum LoginStyle {
    case newUser(User?)
    case returningUser(User)
}

// MARK: - Login Actions Protocol
protocol LoginActions {
    func handleAppleSignIn()
    func handleFaceIDSignIn()
    func handleTermsAndPrivacyTap()
    func changeUser()
}

// MARK: - Minimal Modern Login Screen
struct LoginScreenView: View {
    @EnvironmentObject var appState: AppStateManager
    @State var loginStyle: LoginStyle
    
    /// UI related variables
    @State private var showContent = false
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOffset: CGFloat = -200
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var cardOffset: CGFloat = 300
    @State private var showFooter = false
    
    var body: some View {
        VStack(spacing: Constraint.padding) {
            logoSection
            Spacer()
            switch loginStyle {
            case .newUser:
                newUserLoginCard
            case .returningUser(let user):
                returningUserCard(for: user)
            }
            Spacer()
            footerSection
        }
        .addAnimatedBackground()
        .onAppear { animateEntrance() }
    }

    // MARK: - View Components
    private var logoSection: some View {
        VStack(spacing: Constraint.padding) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.3), .clear],
                            center: .center,
                            startRadius: Constraint.smallPadding,
                            endRadius: Constraint.largeImageSize
                        )
                    )
                    .frame(
                        width: Constraint.regularImageSize/2,
                        height: Constraint.regularImageSize/2
                    )
                    .blur(radius: Constraint.shadowRadius)
                
                ZStack {
                    Circle()
                        .fill(.customWhiteSand)
                        .frame(
                            width: Constraint.largeImageSize/2,
                            height: Constraint.largeImageSize/2
                        )
                        .overlay(
                            Circle().stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        )
                    
                    Image(uiImage: Bundle.main.icon ?? UIImage())
                        .resizable()
                        .frame(
                            width: Constraint.regularImageSize/2,
                            height: Constraint.regularImageSize/2
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .white,
                                    .white.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(logoScale)
                .offset(y: logoOffset)
            }
            VStack(spacing: Constraint.padding) {
                CustomTextView("FundBud", font: .titleLargeBold, color: .white)
                CustomTextView("Know exactly what you can spend!", font: .titleSmall, color: .white.opacity(Constraint.Opacity.high))
            }
            .opacity(showContent ? 1 : 0)
        }
    }
    
    // MARK: - New User Login Card
    private var newUserLoginCard: some View {
        VStack(spacing: Constraint.padding) {
            CustomTextView("Get Started", font: .bodyLargeBold, color: .customRichBlack)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)

            VStack(spacing: Constraint.padding) {
                LoginButtonView(
                    title: "Continue with Apple",
                    icon: "applelogo",
                    isApple: true,
                    isSelected: false
                ) {
                    appState.enableLoadingView()
                    appState.handleAppleSignIn()
                }

                // Face ID login option if user exists
                if case let .newUser(user) = loginStyle, user != nil {
                    faceIDLoginOption
                }
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .padding(Constraint.largePadding)
        .background(cardBackground)
        .offset(y: cardOffset)
        .padding(.horizontal, Constraint.padding)
    }
    
    /// Common card background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Constraint.cornerRadius)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(Constraint.Opacity.low),
                            .white.opacity(Constraint.Opacity.tiny)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: Constraint.smallLineLenght
                )
            )
            .shadow(
                color: .black.opacity(Constraint.Opacity.tiny),
                radius: Constraint.largeShadowRadius,
                x: .zero,
                y: Constraint.shadowRadius
            )
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
    }

    private var footerSection: some View {
        VStack(spacing: Constraint.padding) {
            // Switch User Button (only for returning users)
            if case .returningUser = loginStyle {
                switchUserButton
            }
            
            SecureAndPrivateView(onTap: appState.handleTermsAndPrivacyTap)
        }
        .opacity(showFooter ? Constraint.Opacity.high : 0)
        .offset(y: showFooter ? 0 : 20)
        .padding(.bottom, Constraint.largePadding)
    }
    
    // MARK: - Face ID Login Option
    private var faceIDLoginOption: some View {
        VStack(spacing: Constraint.regularPadding) {
            // Divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.customRichBlack.opacity(Constraint.Opacity.low))
                
                CustomTextView(
                    "or",
                    font: .labelMedium,
                    color: .customRichBlack.opacity(Constraint.Opacity.medium)
                )
                .padding(.horizontal, Constraint.smallPadding)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.customRichBlack.opacity(Constraint.Opacity.low))
            }
            
            // Face ID Button
            Button {
                appState.handleFaceIDSignIn()
            } label: {
                VStack(spacing: Constraint.smallPadding) {
                    Image(systemName: "faceid")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.customOliveGreen, .customBurgundy],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    CustomTextView(
                        "Sign in with Face ID",
                        font: .bodySmall,
                        color: .customRichBlack.opacity(Constraint.Opacity.high)
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constraint.regularPadding)
                .background(
                    RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                        .fill(.customOliveGreen.opacity(Constraint.Opacity.tiny))
                        .overlay(
                            RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                                .stroke(.customOliveGreen.opacity(Constraint.Opacity.low), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    private var switchUserButton: some View {
        Button {
            withAnimation {
                if case let .returningUser(user) = loginStyle {
                   loginStyle = .newUser(user)
                }
            }
            appState.changeUser()
        } label: {
            HStack(spacing: Constraint.smallPadding) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(Constraint.Opacity.medium))
                
                CustomTextView(
                    "Switch User",
                    font: .labelMedium,
                    color: .white.opacity(Constraint.Opacity.medium)
                )
            }
            .padding(.horizontal, Constraint.regularPadding)
            .padding(.vertical, Constraint.smallPadding)
            .background(
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                    .fill(.ultraThinMaterial.opacity(Constraint.Opacity.low))
                    .overlay(
                        RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                            .stroke(.white.opacity(Constraint.Opacity.low), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Methods
    private func animateEntrance() {
        /// 1. Logo slides down and scales up
        withAnimation(.smooth()) {
            logoScale = 1.0
            logoOffset = 0
        }
        
        /// 2. Title appears
        withAnimation(.smooth(duration: 0.6)) {
            showTitle = true
        }
        
        /// 3. Subtitle appears
        withAnimation(.smooth(duration: 0.6)) {
            showSubtitle = true
        }
        
        /// 4. Welcome back card slides up
        withAnimation(.smooth()) {
            cardOffset = 0
            showContent = true
        }
        
        // 5. Footer appears last
        withAnimation(.smooth(duration: 0.6)) {
            showFooter = true
        }
    }
    
    private func handleSignIn(_ type: String, action: @escaping () -> Void) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        action()
    }
    
    private func returningUserCard(for user: User) -> some View {
        VStack(spacing: Constraint.largePadding * 2) {
            /// Personalized greeting
            VStack(spacing: Constraint.smallPadding) {
                let greeting = user.firstName.isEmpty ? "Hi!" : "Hi \(user.firstName)!"
                CustomTextView(greeting, font: .titleLargeBold, color: .customRichBlack.opacity(Constraint.Opacity.high))
                CustomTextView("Good to see you again", font: .bodySmall, color: .customRichBlack.opacity(Constraint.Opacity.medium))
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -20)

            returningUserFaceIDPrompt(for: user)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            
        }
        .padding(Constraint.largePadding)
        .background(cardBackground)
        .offset(y: cardOffset)
        .padding(.horizontal, Constraint.padding)
    }

    // Separate Face ID prompt view
    private func returningUserFaceIDPrompt(for user: User) -> some View {
        VStack(spacing: Constraint.regularPadding) {
            VStack(spacing: Constraint.regularPadding) {
                CustomTextView("Would you like to use Face ID?", font: .bodyLarge, color: .customRichBlack)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 10)
                
                Image(systemName: "faceid")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.customRichBlack, .customRichBlack.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: Constraint.regularImageSize / 3,
                           height: Constraint.regularImageSize / 3)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .onTapGesture {
                        appState.handleFaceIDSignIn()
                    }
            }
        }
    }
}
