import SwiftUI

// MARK: - Onboarding Container View
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showContent = false
    let onboardingPages = OnboardingPage.allPages

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    .customOliveGreen.opacity(0.8),
                    .customBurgundy.opacity(0.6),
                    .customRichBlack.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if showContent {
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: onboardingPages[index],
                            isCurrentPage: currentPage == index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                VStack(spacing: Constraint.padding) {
                    Spacer()
                    // Custom Page Indicator
                    HStack(spacing: Constraint.smallPadding) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? .white : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    
                    // Action Button
                    Button {
                        if currentPage < onboardingPages.count - 1 {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        HStack {
                            CustomTextView(
                                currentPage == onboardingPages.count - 1 ? "Get Started" : "Continue",
                                font: .labelLargeBold,
                                color: .customRichBlack
                            )
                            
                            if currentPage < onboardingPages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.customRichBlack)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constraint.largePadding)
                        .background(
                            RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                                .fill(.white)
                                .shadow(
                                    color: .black.opacity(0.2),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        )
                    }
                    .padding(.horizontal, Constraint.largePadding)
                    
                    // Skip Button
                    if currentPage < onboardingPages.count - 1 {
                        Button {
                            completeOnboarding()
                        } label: {
                            CustomTextView(
                                "Skip",
                                font: .labelMedium,
                                color: .white.opacity(0.7)
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
    
    private func completeOnboarding() {
        if currentPage != onboardingPages.count - 1 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentPage = onboardingPages.count - 1
            }
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
               UserAuthService.shared.completeOnboarding()
           }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let systemImage: String
    let accentColor: Color
    let features: [String]

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to FundBud!",
            subtitle: "Smart Daily Budget Tracker",
            description: "Set your daily spending limit and track every expense in real-time.",
            systemImage: "dollarsign.circle.fill",
            accentColor: .customOliveGreen,
            features: [
                "Set daily spending limits",
                "Real-time expense tracking"
            ]
        ),
        OnboardingPage(
            title: "Your Data Stays Private",
            subtitle: "100% Privacy & Security",
            description: "All your financial data is stored securely in your personal cloud. Never shared with third parties.",
            systemImage: "lock.shield.fill",
            accentColor: .customBurgundy,
            features: [
                "Data stored in your private account",
                "Protected with biometric authentication"
            ]
        ),
        OnboardingPage(
            title: "Daily Budget System",
            subtitle: "Simple & Effective",
            description: "Your daily limit resets every day. Add expenses and watch your remaining budget update instantly.",
            systemImage: "calendar.circle.fill",
            accentColor: .customGold,
            features: [
                "Daily limit resets automatically",
                "Expenses subtract from your budget"
            ]
        ),
        OnboardingPage(
            title: "Start Budgeting Today",
            subtitle: "Take Control of Your Spending",
            description: "Ready to know exactly what you can spend every day? Let's get started!",
            systemImage: "checkmark.circle.fill",
            accentColor: .customOliveGreen,
            features: [
                "Set your first daily limit",
                "Track expenses immediately"
            ]
        )
    ]
}
