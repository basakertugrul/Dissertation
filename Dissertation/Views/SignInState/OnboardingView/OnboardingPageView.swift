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
            title: NSLocalizedString("onboarding_page1_title", comment: ""),
            subtitle: NSLocalizedString("onboarding_page1_subtitle", comment: ""),
            description: NSLocalizedString("onboarding_page1_description", comment: ""),
            systemImage: "dollarsign.circle.fill",
            accentColor: .customOliveGreen,
            features: [
                NSLocalizedString("onboarding_page1_feature1", comment: ""),
                NSLocalizedString("onboarding_page1_feature2", comment: "")
            ]
        ),
        OnboardingPage(
            title: NSLocalizedString("onboarding_page2_title", comment: ""),
            subtitle: NSLocalizedString("onboarding_page2_subtitle", comment: ""),
            description: NSLocalizedString("onboarding_page2_description", comment: ""),
            systemImage: "lock.shield.fill",
            accentColor: .customBurgundy,
            features: [
                NSLocalizedString("onboarding_page2_feature1", comment: ""),
                NSLocalizedString("onboarding_page2_feature2", comment: "")
            ]
        ),
        OnboardingPage(
            title: NSLocalizedString("onboarding_page3_title", comment: ""),
            subtitle: NSLocalizedString("onboarding_page3_subtitle", comment: ""),
            description: NSLocalizedString("onboarding_page3_description", comment: ""),
            systemImage: "calendar.circle.fill",
            accentColor: .customGold,
            features: [
                NSLocalizedString("onboarding_page3_feature1", comment: ""),
                NSLocalizedString("onboarding_page3_feature2", comment: "")
            ]
        ),
        OnboardingPage(
            title: NSLocalizedString("onboarding_page4_title", comment: ""),
            subtitle: NSLocalizedString("onboarding_page4_subtitle", comment: ""),
            description: NSLocalizedString("onboarding_page4_description", comment: ""),
            systemImage: "checkmark.circle.fill",
            accentColor: .customOliveGreen,
            features: [
                NSLocalizedString("onboarding_page4_feature1", comment: ""),
                NSLocalizedString("onboarding_page4_feature2", comment: "")
            ]
        )
    ]
}
