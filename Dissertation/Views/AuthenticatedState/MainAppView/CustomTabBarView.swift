import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: CustomTabBarSection
    @Binding var showAddExpenseSheet: Bool
    @State private var isExpanded: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var shakeAnimation: Bool = false
    @Binding var willOpenCameraView: Bool
    @Binding var willOpenVoiceRecording: Bool

    var body: some View {
        HStack(spacing: 0) {
            /// Balance Tab
            TabButton(
                icon: "chart.bar.xaxis",
                isSelected: selectedTab == .balance
            ) {
                HapticManager.shared.trigger(.navigation)
                selectedTab = .balance
            }
            .offset(y: -8) // Move up for curved effect

            Spacer()

            /// Dynamic Add Button System
            DynamicAddButton(
                isExpanded: $isExpanded,
                dragOffset: $dragOffset,
                shakeAnimation: $shakeAnimation,
                onAddTap: {
                    HapticManager.shared.trigger(.add)
                    showAddExpenseSheet = true
                },
                onCameraTap: {
                    HapticManager.shared.trigger(.buttonTap)
                    willOpenCameraView = true
                    // Stop shake and collapse immediately
                    shakeAnimation = false
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded = false
                        dragOffset = .zero
                    }
                },
                onVoiceTap: {
                    HapticManager.shared.trigger(.buttonTap)
                    willOpenVoiceRecording = true
                    // Stop shake and collapse immediately
                    shakeAnimation = false
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded = false
                        dragOffset = .zero
                    }
                }
            )
            .offset(y: -8) // Move up for curved effect

            Spacer()

            /// Expenses Tab
            TabButton(
                icon: "list.bullet",
                isSelected: selectedTab == .expenses
            ) {
                HapticManager.shared.trigger(.navigation)
                selectedTab = .expenses
            }
            .offset(y: -8) // Move up for curved effect
        }
        .padding(.horizontal, Constraint.largePadding)
        .padding(.bottom, Constraint.padding)
        .background(
            Rectangle()
                .fill(.customRichBlack)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Extensions
extension CustomTabBar {
    
    // MARK: - Dynamic Add Button System
    struct DynamicAddButton: View {
        @Binding var isExpanded: Bool
        @Binding var dragOffset: CGSize
        @Binding var shakeAnimation: Bool
        let onAddTap: () -> Void
        let onCameraTap: () -> Void
        let onVoiceTap: () -> Void
        
        @State private var buttonScale: CGFloat = 1.0
        
        var body: some View {
            ZStack {
                // Three buttons side by side when expanded
                if isExpanded {
                    HStack(spacing: 30) {
                        // Camera Button (Left)
                        FloatingButton(
                            icon: "camera.fill",
                            color: .customBurgundy,
                            action: onCameraTap
                        )
                        .offset(x: shakeAnimation ? -3 : 3)
                        .transition(.scale.combined(with: .opacity))
                        
                        // Main Add Button (Center)
                        MainFloatingButton(
                            isExpanded: isExpanded,
                            buttonScale: buttonScale,
                            dragOffset: dragOffset,
                            onTap: onAddTap
                        )
                        .offset(x: shakeAnimation ? 2 : -2)
                        
                        // Voice Button (Right)
                        FloatingButton(
                            icon: "waveform",
                            color: .customOliveGreen,
                            action: onVoiceTap
                        )
                        .offset(x: shakeAnimation ? 3 : -3)
                        .transition(.scale.combined(with: .opacity))
                    }
                    .offset(y: Constraint.mainButtonOffset)
                } else {
                    // Only main button when collapsed
                    MainFloatingButton(
                        isExpanded: isExpanded,
                        buttonScale: buttonScale,
                        dragOffset: dragOffset,
                        onTap: onAddTap
                    )
                    .offset(y: Constraint.mainButtonOffset)
                }
            }
            .onLongPressGesture(
                minimumDuration: 0.2,
                pressing: { isPressing in
                    if isPressing {
                        HapticManager.shared.trigger(.longPress)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isExpanded = true
                            buttonScale = 1.1
                        }
                        // Start shake animation
                        withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                            shakeAnimation = true
                        }
                    } else if isExpanded {
                        // Stop shake animation
                        shakeAnimation = false
                        // Auto collapse after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isExpanded = false
                                buttonScale = 1.0
                                dragOffset = .zero
                            }
                        }
                    }
                },
                perform: {}
            )
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isExpanded)
        }
    }
    
    // MARK: - Main Floating Button
    struct MainFloatingButton: View {
        let isExpanded: Bool
        let buttonScale: CGFloat
        let dragOffset: CGSize
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                Circle()
                    .fill(.customGold)
                    .frame(width: Constraint.extremeSize, height: Constraint.extremeSize)
                    .shadow(
                        color: .customGold.opacity(0.4),
                        radius: isExpanded ? 8 : 5,
                        x: 0,
                        y: isExpanded ? 3 : 2
                    )
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: Constraint.regularIconSize, weight: .bold))
                            .foregroundStyle(.customWhiteSand)
                    )
            }
            .buttonStyle(ElasticButtonStyle())
        }
    }
    
    // MARK: - Floating Button
    struct FloatingButton: View {
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Circle()
                    .fill(color)
                    .frame(width: Constraint.extremeSize, height: Constraint.extremeSize)
                    .shadow(
                        color: color.opacity(0.4),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: Constraint.regularIconSize, weight: .medium))
                            .foregroundStyle(.customWhiteSand)
                    )
            }
            .buttonStyle(ElasticButtonStyle())
        }
    }

    // MARK: - Tab Button
    struct TabButton: View {
        let icon: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: Constraint.tinyPadding) {
                    Image(systemName: icon)
                        .font(.system(size: Constraint.mediumIconSize, weight: .medium))
                        .foregroundStyle(isSelected ? .customWhiteSand : .customWhiteSand.opacity(Constraint.Opacity.medium))
                    
                    Circle()
                        .fill(.customWhiteSand)
                        .frame(width: Constraint.mediumSize, height: Constraint.mediumSize)
                        .opacity(isSelected ? 1 : 0)
                }
                .frame(width: Constraint.extremeSize, height: Constraint.extremeSize)
            }
            .buttonStyle(SoftButtonStyle())
            .animation(.easeOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Button Styles
struct ElasticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
