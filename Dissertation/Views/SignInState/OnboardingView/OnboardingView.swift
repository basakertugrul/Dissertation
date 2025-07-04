import SwiftUI

// MARK: - Fixed Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var userAuthService = UserAuthService.shared
    @State private var currentPage = 0
    
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
            
            VStack(spacing: 0) {
                // Main Content
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
                
                // Bottom Section
                VStack(spacing: Constraint.padding) {
                    // Page Dots
                    HStack(spacing: Constraint.smallPadding) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? .white : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    
                    // Continue Button
                    Button {
                        HapticManager.shared.trigger(.buttonTap)
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
                                currentPage == onboardingPages.count - 1 ? NSLocalizedString("get_started", comment: "") : NSLocalizedString("continue", comment: ""),
                                font: .titleSmallBold,
                                color: .customRichBlack
                            )
                            
                            if currentPage < onboardingPages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.customRichBlack)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                    }
                    
                    // Skip Button
                    if currentPage < onboardingPages.count - 1 {
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentPage = onboardingPages.count - 1
                            }
                        } label: {
                            CustomTextView(
                                NSLocalizedString("skip", comment: ""),
                                font: .labelMedium,
                                color: .white.opacity(0.7)
                            )
                        }
                    }
                }
                .padding(.horizontal, Constraint.largePadding)
                .padding(.bottom, Constraint.largePadding)
            }
        }
    }
    
    private func completeOnboarding() {
        HapticManager.shared.trigger(.success)
        UserAuthService.shared.completeOnboarding()
    }
}
