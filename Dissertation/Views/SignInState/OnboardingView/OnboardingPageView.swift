import SwiftUI

// MARK: - Fixed Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let isCurrentPage: Bool
    
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: Constraint.largePadding) {
            Spacer()
            iconSection
            
            contentSection
            
            featuresSection
            Spacer()
        }
        .padding(.horizontal, Constraint.padding)
        .onAppear {
            if isCurrentPage {
                animateEntrance()
            }
        }
        .onChange(of: isCurrentPage) { _, newValue in
            if newValue {
                resetAndAnimate()
            }
        }
    }
    
    // MARK: - Icon Section
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 120, height: 120)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            Image(systemName: page.systemImage)
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [page.accentColor, page.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .scaleEffect(showContent ? 1.0 : 0.8)
        .opacity(showContent ? 1.0 : 0.0)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(spacing: Constraint.padding) {
            // Title
            CustomTextView(
                page.title,
                font: .titleLargeBold,
                color: .white
            )
            .multilineTextAlignment(.center)
            
            // Subtitle
            CustomTextView(
                page.subtitle,
                font: .titleSmall,
                color: page.accentColor
            )
            .multilineTextAlignment(.center)
            .shadow(color: .black, radius: Constraint.largeShadowRadius)
            
            // Description
            CustomTextView(
                page.description,
                font: .bodySmall,
                color: .white.opacity(0.85)
            )
            .multilineTextAlignment(.center)
            .lineLimit(nil)
        }
        .opacity(showContent ? 1.0 : 0.0)
        .offset(y: showContent ? 0 : 20)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: Constraint.smallPadding) {
            ForEach(Array(page.features.enumerated()), id: \.offset) { index, feature in
                HStack(spacing: Constraint.smallPadding) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(page.accentColor)
                    
                    CustomTextView(
                        feature,
                        font: .labelMedium,
                        color: .white.opacity(0.9)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, Constraint.smallPadding)
            }
        }
        .opacity(showContent ? 1.0 : 0.0)
        .offset(y: showContent ? 0 : 15)
    }
    
    // MARK: - Simple Animations
    private func animateEntrance() {
        withAnimation(.easeInOut(duration: 0.6).delay(0.2)) {
            showContent = true
        }
    }
    
    private func resetAndAnimate() {
        showContent = false
        animateEntrance()
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
            title: "Welcome to FundBud",
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
            title: "Your Data Stays Local",
            subtitle: "100% Privacy & Security",
            description: "All your financial data is stored securely on your phone. Never shared or uploaded.",
            systemImage: "lock.shield.fill",
            accentColor: .customBurgundy,
            features: [
                "All data stays on your phone",
                "Protected with Face ID & Touch ID"
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
