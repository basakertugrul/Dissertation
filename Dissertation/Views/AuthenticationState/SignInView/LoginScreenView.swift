import SwiftUI

// MARK: - Login Style Enum
enum LoginStyle {
    case newUser
    case returningUser(User)
}

// MARK: - Login Actions Protocol
protocol LoginActions {
    func handleAppleSignIn()
    func handleGoogleSignIn()
    func handleFaceIDSignIn()
    func handleAlternativeSignIn()
    func handleTermsTap()
    func handlePrivacyTap()
}

// MARK: - Minimal Modern Login Screen
struct LoginScreenView: View {
    let loginStyle: LoginStyle
    let actions: LoginActions
    
    @Binding var isLoading: Bool

    /// UI related variables
    @State private var showContent = false
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOffset: CGFloat = -200
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var cardOffset: CGFloat = 300
    @State private var showFooter = false
    @State private var selectedButton: String? = nil
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
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
        }
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
                        .fill(.ultraThinMaterial)
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
                CustomTextView("BudgetMate", font: .titleLargeBold, color: .white)
                CustomTextView("Know exactly what you can spend!", font: .titleSmall, color: .white.opacity(Constraint.Opacity.high))
            }
            .opacity(showContent ? 1 : 0)
        }
    }
    
    // MARK: - New User Login Card
    private var newUserLoginCard: some View {
        VStack(spacing: Constraint.regularPadding) {
            VStack(spacing: Constraint.smallPadding) {
                CustomTextView("Get Started", font: .bodyLargeBold, color: .customRichBlack)
                CustomTextView("Choose your preferred login method", font: .bodySmall, color: .customRichBlack.opacity(Constraint.Opacity.medium))
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -20)
            
            VStack(spacing: Constraint.padding) {
                LoginButtonView(
                    title: "Continue with Apple",
                    icon: "applelogo",
                    isApple: true,
                    isSelected: selectedButton == "apple"
                ) {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                    handleSignIn("apple", action: actions.handleAppleSignIn)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                LoginButtonView(
                    title: "Continue with Google",
                    icon: "globe",
                    isGlass: true,
                    isSelected: selectedButton == "google"
                ) {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                    handleSignIn("google", action: actions.handleGoogleSignIn)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
        }
        .padding(Constraint.largePadding)
        .background(cardBackground)
        .offset(y: cardOffset)
        .padding(.horizontal, Constraint.padding)
    }
    
    // MARK: - Returning User Card
    private func returningUserCard(for user: User) -> some View {
        VStack(spacing: Constraint.largePadding) {
            /// Personalized greeting
            VStack(spacing: Constraint.smallPadding) {
                CustomTextView("Hi \(user.fullName)!", font: .titleLargeBold, color: .customRichBlack)
                CustomTextView("Good to see you again", font: .bodySmall, color: .customRichBlack.opacity(Constraint.Opacity.medium))
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -20)

            /// Face ID prompt
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
                        handleSignIn("biometric", action: actions.handleFaceIDSignIn)
                    }

                VStack(spacing: Constraint.padding) {
                    Button {
                        actions.handleAlternativeSignIn()
                    } label: {
                        CustomTextView("Use another method", font: .labelMedium, color: .customRichBlack.opacity(Constraint.Opacity.high))
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 10)
                    .padding(.bottom, Constraint.padding)
                }
            }
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
        VStack(spacing: Constraint.tinyPadding) {
            CustomTextView("Secure & Private", font: .bodyLarge, color: .customWhiteSand)
            
            HStack(spacing: Constraint.smallPadding) {
                Button(action: actions.handleTermsTap) {
                    CustomTextView("Terms", font: .labelSmallBold, color: .customWhiteSand)
                }
                Circle()
                    .fill(.customWhiteSand)
                    .frame(width: 4, height: 4)
                Button(action: actions.handlePrivacyTap) {
                    CustomTextView("Privacy", font: .labelSmallBold, color: .customWhiteSand)
                }
            }
        }
        .opacity(showFooter ? Constraint.Opacity.high : 0)
        .offset(y: showFooter ? 0 : 20)
        .padding(.bottom, Constraint.largePadding)
    }

    // MARK: - Methods
    private func animateEntrance() {
        // 1. Logo slides down and scales up
        withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOffset = 0
        }
        
        // 2. Title appears
        withAnimation(.easeOut(duration: 0.6)) {
            showTitle = true
        }
        
        // 3. Subtitle appears
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            showSubtitle = true
        }
        
        // 4. Welcome back card slides up
        withAnimation(.spring(response: 1.0, dampingFraction: 0.9).delay(3)) {
            cardOffset = 0
            showContent = true
        }
        
        // 5. Footer appears last
        withAnimation(.easeOut(duration: 0.6).delay(4)) {
            showFooter = true
        }
    }
    
    private func handleSignIn(_ type: String, action: @escaping () -> Void) {
        selectedButton = type
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// MARK: - Animated Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [.customOliveGreen, .customBurgundy, .customGold],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.smooth(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}
