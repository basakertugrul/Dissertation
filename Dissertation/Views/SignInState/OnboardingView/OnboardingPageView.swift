import SwiftUI

// MARK: - Simplified Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let isCurrentPage: Bool
    
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showDescription = false
    @State private var showFeatures = false
    
    var body: some View {
        VStack(spacing: Constraint.smallPadding) {
            Spacer()

            iconSection
            
            contentSection
            
            Spacer()
        }
        .padding(.horizontal, Constraint.largePadding)
        .onAppear {
            if isCurrentPage {
                animateEntrance()
            }
        }
        .onChange(of: isCurrentPage) { _, newValue in
            if newValue {
                resetAnimations()
                animateEntrance()
            }
        }
    }
    
    private var iconSection: some View {
        ZStack {
            // Simple background circle
            Circle()
                .fill(.white.opacity(0.9))
                .frame(
                    width: Constraint.regularImageSize * 0.7,
                    height: Constraint.regularImageSize * 0.7
                )
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            
            // Icon
            Image(systemName: page.systemImage)
                .font(.system(size: 56, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            page.accentColor,
                            page.accentColor.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .scaleEffect(showIcon ? 1.0 : 0.5)
        .opacity(showIcon ? 1.0 : 0.0)
    }
    
    private var contentSection: some View {
        VStack(spacing: Constraint.padding) {
            // Title
            CustomTextView(
                page.title,
                font: .titleLargeBold,
                color: .white
            )
            .multilineTextAlignment(.center)
            .opacity(showTitle ? 1.0 : 0.0)
            .offset(y: showTitle ? 0 : 20)
            
            // Subtitle
            CustomTextView(
                page.subtitle,
                font: .titleSmall,
                color: page.accentColor
            )
            .multilineTextAlignment(.center)
            .shadow(
                color: .customRichBlack,
                radius: Constraint.largeShadowRadius + Constraint.shadowRadius,
                x: .zero,
                y: 4
            )
            .opacity(showSubtitle ? 1.0 : 0.0)
            .offset(y: showSubtitle ? 0 : 15)
            
            // Description
            CustomTextView(
                page.description,
                font: .labelMedium,
                color: .white.opacity(0.8)
            )
            .multilineTextAlignment(.center)
            .opacity(showDescription ? 1.0 : 0.0)
            .offset(y: showDescription ? 0 : 15)
            
            // Simplified Features
            VStack(spacing: Constraint.regularPadding) {
                ForEach(Array(page.features.prefix(2).enumerated()), id: \.offset) { index, feature in
                    HStack(spacing: Constraint.regularPadding) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(page.accentColor)
                        
                        CustomTextView(
                            feature,
                            font: .bodySmall,
                            color: .white.opacity(0.9)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .opacity(showFeatures ? 1.0 : 0.0)
                    .offset(x: showFeatures ? 0 : -30)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                        value: showFeatures
                    )
                }
            }
        }
    }
    
    // MARK: - Simplified Animation Methods
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showIcon = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showTitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSubtitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showDescription = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showFeatures = true
            }
        }
    }
    
    private func resetAnimations() {
        showIcon = false
        showTitle = false
        showSubtitle = false
        showDescription = false
        showFeatures = false
    }
}
