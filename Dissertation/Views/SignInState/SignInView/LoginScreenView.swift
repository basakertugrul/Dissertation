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
}

// MARK: - Enhanced Modern Login Screen
struct LoginScreenView: View {
    @EnvironmentObject var appState: AppStateManager
    @State var loginStyle: LoginStyle

    /// Enhanced UI related variables
    @State private var showContent = false
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOffset: CGFloat = -200
    @State private var logoRotation: Double = 0
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var cardOffset: CGFloat = 300
    @State private var showFooter = false
    @State private var pulseAnimation = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var willShowTermsAndPrivacy: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            /// Logo section
            logoSection

            /// Main content area
            switch loginStyle {
            case .newUser:
                newUserLoginCard
                    .padding(.vertical, Constraint.extremePadding)
            case let .returningUser(user):
                returningUserCard(for: user)
                    .padding(.vertical, Constraint.extremePadding)
                    .onAppear {
                        DispatchQueue.main.async {
                            appState.authenticateUserOnLaunch()
                        }
                    }
            }

            /// Footer Section
            footerSection
        }
        .addAnimatedBackground()
        .onAppear {
            animateEntrance()
            startShimmerAnimation()
        }
        .showLegalInformationAlert(isPresented: $willShowTermsAndPrivacy)
    }

    // MARK: - Enhanced View Components
    private var logoSection: some View {
        VStack(spacing: Constraint.largePadding) {
            ZStack {
                /// Enhanced glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(Constraint.Opacity.medium),
                                .white.opacity(Constraint.Opacity.low),
                                .clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: Constraint.extremeIconSize
                        )
                    )
                    .frame(
                        width: Constraint.regularImageSize * 0.8,
                        height: Constraint.regularImageSize * 0.8
                    )
                    .blur(radius: Constraint.shadowRadius * 1.5)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .opacity(pulseAnimation ? 0.7 : 0.4)

                /// Logo container
                ZStack {
                    /// Outer ring with gradient border
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .customWhiteSand.opacity(Constraint.Opacity.high),
                                    .customWhiteSand
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(
                            width: Constraint.largeImageSize / 2,
                            height: Constraint.largeImageSize / 2
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(Constraint.Opacity.hidden),
                                            .white.opacity(Constraint.Opacity.medium),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(
                            color: .black.opacity(Constraint.Opacity.high),
                            radius: 8,
                            x: 0,
                            y: 4
                        )

                    /// Logo
                    Image(uiImage: Bundle.main.icon ?? UIImage())
                        .resizable()
                        .frame(
                            width: Constraint.regularImageSize * 0.5,
                            height: Constraint.regularImageSize * 0.5
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .white,
                                    .white.opacity(0.9),
                                    .white.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: .black.opacity(0.2),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                }
                .scaleEffect(logoScale)
                .offset(y: logoOffset)
                .rotationEffect(.degrees(logoRotation))
            }

            /// Title section
            VStack(spacing: Constraint.regularPadding) {
                /// Main title
                ZStack {
                    CustomTextView("FundBud", font: .titleLargeBold, color: .white)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(Constraint.Opacity.medium),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .offset(x: shimmerOffset)
                            .mask(
                                CustomTextView("FundBud", font: .titleLargeBold, color: .white)
                            )
                        )
                }
                .opacity(showTitle ? 1 : 0)
                .scaleEffect(showTitle ? 1 : 0.8)
                
                /// Subtitle
                CustomTextView(
                    "Know exactly what you can spend!",
                    font: .titleSmall,
                    color: .white.opacity(Constraint.Opacity.high)
                )
                .opacity(showSubtitle ? 1 : .zero)
                .offset(y: showSubtitle ? .zero : 10)
                .multilineTextAlignment(.center)
            }
            .opacity(showContent ? 1 : 0)
        }
    }

    // MARK: - Enhanced New User Login Card
    private var newUserLoginCard: some View {
        VStack(spacing: Constraint.largePadding) {
            // Header
            VStack(spacing: Constraint.smallPadding) {
                CustomTextView("Get Started", font: .bodyLargeBold, color: .customRichBlack)
                    .opacity(showContent ? 1 : .zero)
                    .offset(y: showContent ? .zero : -20)
                
                CustomTextView(
                    "Choose your preferred sign-in method",
                    font: .bodySmall,
                    color: .customRichBlack.opacity(0.7)
                )
                .opacity(showContent ? 1 : .zero)
                .offset(y: showContent ? .zero : -15)
            }
            .padding(.top, Constraint.padding)

            VStack(spacing: Constraint.smallPadding) {
                // Apple Sign In button
                LoginButtonView(
                    title: "Continue with Apple",
                    icon: "applelogo",
                    isApple: true,
                    isSelected: false
                ) {
                    appState.enableLoadingView()
                    appState.handleAppleSignIn()
                }
                .padding(Constraint.padding)

                // Face ID login option if user exists
                if case let .newUser(user) = loginStyle, user != nil {
                    enhancedFaceIDLoginOption
                }
            }
            .opacity(showContent ? 1 : .zero)
            .offset(y: showContent ? .zero : 20)
        }
        .background(enhancedCardBackground)
        .offset(y: cardOffset)
        .padding(.horizontal, Constraint.largePadding)
    }

    /// Enhanced card background with better depth
    private var enhancedCardBackground: some View {
        RoundedRectangle(cornerRadius: Constraint.cornerRadius)
            .fill(.customWhiteSand.opacity(Constraint.Opacity.low))
            .overlay(
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                    .stroke(
                        .gray,
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: .black.opacity(Constraint.Opacity.low),
                radius: Constraint.largeShadowRadius,
                x: .zero,
                y: 10
            )
            .shadow(
                color: .black.opacity(Constraint.Opacity.low),
                radius:  Constraint.largeShadowRadius,
                x: .zero,
                y: 2
            )
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
            .scaleEffect(showContent ? 1 : 0.95)
    }

    private var footerSection: some View {
        VStack(spacing: Constraint.largePadding) {
            if case .returningUser = loginStyle {
                enhancedSwitchUserButton
            }

            SecureAndPrivateView(onTap: {
                DispatchQueue.main.async {
                    withAnimation {
                        willShowTermsAndPrivacy = true
                    }
                }
            })
        }
        .opacity(showFooter ? 1 : 0)
        .offset(y: showFooter ? 0 : 30)
        .padding(.bottom, Constraint.largePadding)
    }
    
    // MARK: - Enhanced Face ID Login Option
    private var enhancedFaceIDLoginOption: some View {
        VStack(spacing: .zero) {
            // Enhanced divider
            HStack {
                DividerView()

                CustomTextView(
                    "or",
                    font: .labelMedium,
                    color: .customRichBlack.opacity(Constraint.Opacity.high)
                )
                .padding(.horizontal, Constraint.regularPadding)

                DividerView()
            }

            // Enhanced Face ID Button
            Button {
                HapticManager.shared.trigger(.buttonTap)
                appState.handleFaceIDSignIn()
            } label: {
                VStack(spacing: Constraint.regularPadding) {
                    Image(systemName: "faceid")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .customOliveGreen,
                                    .customBurgundy.opacity(Constraint.Opacity.high)
                                ],
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
                .padding(.vertical, Constraint.padding)
            }
            .buttonStyle(.plain)
        }
    }

    private var enhancedSwitchUserButton: some View {
        Button {
            HapticManager.shared.trigger(.navigation)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                if case let .returningUser(user) = loginStyle {
                   loginStyle = .newUser(user)
                }
            }
        } label: {
            HStack(spacing: Constraint.regularPadding) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                CustomTextView(
                    "Switch User",
                    font: .labelMedium,
                    color: .white.opacity(0.8)
                )
            }
            .padding(.horizontal, Constraint.largePadding)
            .padding(.vertical, Constraint.regularPadding)
            .background(
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.15),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Enhanced Methods
    private func animateEntrance() {
        // 1. Logo animation with rotation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOffset = 0
            logoRotation = 360
        }
        
        // 2. Pulse animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
        
        // 3. Title appears with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        // 4. Subtitle appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSubtitle = true
            }
        }
        
        // 5. Content card slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                cardOffset = 0
                showContent = true
            }
        }
        
        // 6. Footer appears last
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showFooter = true
            }
        }
    }
    
    private func startShimmerAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
            shimmerOffset = 200
        }
    }
    
    private func returningUserCard(for user: User) -> some View {
        VStack(spacing: Constraint.padding) {
            /// Enhanced personalized greeting
            CustomTextView("Welcome Back!", font: .titleLargeBold, color: .customRichBlack)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)
                .scaleEffect(showContent ? 1 : 0.9)
            
            enhancedReturningUserFaceIDPrompt(for: user)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(enhancedCardBackground)
        .offset(y: cardOffset)
        .padding(.horizontal, Constraint.largePadding)
    }

    // Enhanced Face ID prompt view
    private func enhancedReturningUserFaceIDPrompt(for user: User) -> some View {
        VStack(spacing: Constraint.largePadding) {
            Button {
                HapticManager.shared.trigger(.buttonTap)
                appState.handleFaceIDSignIn()
            } label: {
                ZStack {
                    // Enhanced glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .customRichBlack.opacity(0.2),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 8)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    
                    // Face ID icon
                    Image(systemName: "faceid")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    .customRichBlack,
                                    .customRichBlack.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .scaleEffect(showContent ? 1 : 0.5)
                }
            }
            .buttonStyle(.plain)
            .opacity(showContent ? 1 : 0)
        }
    }
}
