import SwiftUI

// MARK: - Enhanced Sign In Button Component
struct LoginButtonView: View {
    @EnvironmentObject var appState: AppStateManager
    let title: String
    let icon: String
    var isApple = false
    var isGlass = false
    var isSelected = false
    let action: () -> Void
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Button {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()

            action()
        } label: {
            HStack(spacing: Constraint.regularPadding) {
                // Enhanced icon with better styling
                ZStack {
                    if isApple {
                        // Subtle glow for Apple button
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 15
                                )
                            )
                            .frame(width: 30, height: 30)
                            .blur(radius: 3)
                    }
                    
                    Image(systemName: icon)
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(enhancedTextColor)
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .shadow(
                            color: isApple ? .white.opacity(0.3) : .clear,
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                }
                
                // Enhanced text with shimmer effect for Apple button
                ZStack {
                    CustomTextView(title, font: .labelLargeBold)
                        .foregroundStyle(enhancedTextColor)
                    
                    if isApple {
                        // Shimmer overlay for Apple button
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.4),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .offset(x: shimmerOffset)
                        .mask(
                            CustomTextView(title, font: .labelLargeBold, color: .white)
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.vertical, Constraint.padding)
            .padding(.horizontal, Constraint.regularPadding)
            .background(enhancedBackgroundView)
            .scaleEffect(isPressed ? 0.97 : (isHovered ? 1.02 : 1.0))
            .shadow(
                color: shadowColor,
                radius: isSelected ? Constraint.largeShadowRadius : (isPressed ? 2 : 8),
                x: 0,
                y: isSelected ? 8 : (isPressed ? 1 : 4)
            )
            .overlay(
                // Subtle highlight overlay when pressed
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                    .fill(.white.opacity(isPressed ? 0.1 : 0))
            )
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onAppear {
            if isApple {
                startShimmerAnimation()
            }
        }
    }
    
    // MARK: - Enhanced Color Properties
    private var enhancedTextColor: LinearGradient {
        if isApple {
            return LinearGradient(
                colors: [.white, .white.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isGlass {
            return LinearGradient(
                colors: [.customRichBlack, .customRichBlack.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [.primary, .primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shadowColor: Color {
        if isApple {
            return .black.opacity(0.3)
        } else if isSelected {
            return .customOliveGreen.opacity(0.3)
        }
        return .black.opacity(0.1)
    }
    
    // MARK: - Enhanced Background View
    private var enhancedBackgroundView: some View {
        RoundedRectangle(cornerRadius: Constraint.cornerRadius)
            .fill(backgroundGradient)
            .overlay(
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                    .stroke(borderGradient, lineWidth: borderWidth)
            )
            .overlay(
                // Subtle inner highlight
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(isApple ? 0.4 : 0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .padding(1)
            )
    }
    
    private var backgroundGradient: LinearGradient {
        if isApple {
            return LinearGradient(
                colors: [
                    .customRichBlack,
                    .customRichBlack.opacity(0.9),
                    .customRichBlack.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isGlass {
            return LinearGradient(
                colors: [
                    .customGold.opacity(0.8),
                    .customGold.opacity(0.6),
                    .customGold.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                .clear,
                .clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var borderGradient: LinearGradient {
        if isApple {
            return LinearGradient(
                colors: [
                    .white.opacity(0.3),
                    .white.opacity(0.1),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isGlass {
            return LinearGradient(
                colors: [
                    .customGold.opacity(0.6),
                    .customGold.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                .gray.opacity(0.3),
                .gray.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var borderWidth: CGFloat {
        if isApple || isGlass {
            return 1.5
        }
        return 1
    }
    
    // MARK: - Animation Methods
    private func startShimmerAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
        }
    }
}
