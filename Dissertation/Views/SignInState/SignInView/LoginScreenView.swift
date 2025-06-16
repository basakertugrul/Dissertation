import SwiftUI

// MARK: - Login Style Enum
enum LoginStyle {
    case newUser
    case returningUser(User)
}

// MARK: - Login Actions Protocol
protocol LoginActions {
    func handleAppleSignIn()
    func handleFaceIDSignIn()
    func handleEmailPasswordSignIn(email: String, password: String)
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
    
    /// Email/Password form variables
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showEmailPassword = false
    @State private var isEmailFocused = false
    @State private var isPasswordFocused = false
    @State private var showPassword = false
    @State private var showEmailPasswordForReturningUser = false
    
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
        VStack(spacing: Constraint.padding) {
            CustomTextView("Get Started", font: .bodyLargeBold, color: .customRichBlack)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)

            LoginButtonView(
                title: "Continue with Apple",
                icon: "applelogo",
                isApple: true,
                isSelected: selectedButton == "apple"
            ) {
                isLoading = true
                handleSignIn("apple", action: actions.handleAppleSignIn)
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
        SecureAndPrivateView(handleTermsTap: actions.handleTermsTap, handlePrivacyTap: actions.handlePrivacyTap)
        .opacity(showFooter ? Constraint.Opacity.high : 0)
        .offset(y: showFooter ? 0 : 20)
        .padding(.bottom, Constraint.largePadding)
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
        selectedButton = type
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if type == "apple" {
            actions.handleAppleSignIn()
        }
    }
    
    private func returningUserCard(for user: User) -> some View {
        VStack(spacing: Constraint.largePadding) {
            /// Personalized greeting
            VStack(spacing: Constraint.smallPadding) {
                let greeting = user.firstName.isEmpty ? "Hi!" : "Hi \(user.firstName)!"
                CustomTextView(greeting, font: .titleLargeBold, color: .customRichBlack)
                CustomTextView("Good to see you again", font: .bodySmall, color: .customRichBlack.opacity(Constraint.Opacity.medium))
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -20)

            // Show either Face ID prompt or email/password form
            if showEmailPasswordForReturningUser {
                returningUserEmailPasswordForm
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            } else {
                returningUserFaceIDPrompt(for: user)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .padding(Constraint.largePadding)
        .background(cardBackground)
        .offset(y: cardOffset)
        .padding(.horizontal, Constraint.padding)
    }

    // Separate Face ID prompt view
    private func returningUserFaceIDPrompt(for user: User) -> some View {
        VStack(spacing: Constraint.regularPadding) {
            // Face ID content or email/password button
            if user.hasFaceIDEnabled {
                // Face ID UI
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
                            actions.handleFaceIDSignIn()
                        }
                }
            }
            
            // Always show "Use another method" button
            Button {
                withAnimation(.smooth()) {
                    showEmailPasswordForReturningUser = true
                }
            } label: {
                CustomTextView("Use another method", font: .labelMedium, color: .customRichBlack.opacity(Constraint.Opacity.high))
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 10)
        }
    }

    // Email/password form for returning users
    private var returningUserEmailPasswordForm: some View {
        VStack(spacing: Constraint.regularPadding) {
            // Back button
            HStack {
                Button {
                    withAnimation(.smooth()) {
                        showEmailPasswordForReturningUser = false
                        email = ""
                        password = ""
                    }
                } label: {
                    HStack(spacing: Constraint.tinyPadding) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                        CustomTextView("Back", font: .labelMedium, color: .customRichBlack.opacity(Constraint.Opacity.high))
                    }
                }
                
                Spacer()
            }
            
            VStack(spacing: Constraint.padding) {
                // Email and password fields (same as before)
                CustomTextFieldView(
                    text: $email,
                    placeholder: "Email address",
                    isSecure: false,
                    isFocused: $isEmailFocused,
                    keyboardType: .emailAddress,
                    icon: "envelope"
                )
                
                CustomTextFieldView(
                    text: $password,
                    placeholder: "Password",
                    isSecure: !showPassword,
                    isFocused: $isPasswordFocused,
                    keyboardType: .default,
                    icon: "lock",
                    trailingIcon: showPassword ? "eye.slash" : "eye"
                ) {
                    showPassword.toggle()
                }
                
                // Sign In Button
                Button {
                    if !email.isEmpty && !password.isEmpty {
                        isLoading = true
                        actions.handleEmailPasswordSignIn(email: email, password: password)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            CustomTextView("Sign In", font: .bodySmallBold, color: .white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Constraint.regularPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [.customOliveGreen, .customBurgundy],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                .opacity((email.isEmpty || password.isEmpty) ? Constraint.Opacity.medium : 1)
            }
        }
    }
}

// MARK: - Custom Text Field View
struct CustomTextFieldView: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    @Binding var isFocused: Bool
    let keyboardType: UIKeyboardType
    let icon: String
    let trailingIcon: String?
    let trailingAction: (() -> Void)?
    
    init(
        text: Binding<String>,
        placeholder: String,
        isSecure: Bool = false,
        isFocused: Binding<Bool>,
        keyboardType: UIKeyboardType = .default,
        icon: String,
        trailingIcon: String? = nil,
        trailingAction: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self._isFocused = isFocused
        self.keyboardType = keyboardType
        self.icon = icon
        self.trailingIcon = trailingIcon
        self.trailingAction = trailingAction
    }
    
    var body: some View {
        HStack(spacing: Constraint.smallPadding) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.customRichBlack.opacity(Constraint.Opacity.medium))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
                    
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
                    
            }
            
            if let trailingIcon = trailingIcon {
                Button(action: trailingAction ?? {}) {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.customRichBlack.opacity(Constraint.Opacity.medium))
                }
            }
        }
        .padding(Constraint.regularPadding)
        .background(
            RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                        .stroke(
                            isFocused ?
                                LinearGradient(
                                    colors: [.customOliveGreen, .customBurgundy],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [Color.customRichBlack.opacity(Constraint.Opacity.low)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
        )
    }
}
