import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: CustomTabBarSection
    @Binding var showAddExpenseSheet: Bool
    @State private var showVoiceOption: Bool = false
    @State private var longPressInProgress: Bool = false
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
                withAnimation(.smooth(duration: 0.2)) {
                    selectedTab = .balance
                }
            }

            Spacer()

            /// Main Add Button
            MainAddButton(
                showVoiceOption: $showVoiceOption,
                longPressInProgress: $longPressInProgress,
                onAddTap: {
                    HapticManager.shared.trigger(.add)
                    withAnimation(.smooth) {
                        showAddExpenseSheet = true
                    }
                },
                onVoiceTap: {
                    HapticManager.shared.trigger(.buttonTap)
                    withAnimation(.smooth()) {
                        willOpenVoiceRecording = true
                        showVoiceOption = false
                        longPressInProgress = false
                    }
                },
                onLongPress: { isPressing in
                    if isPressing {
                        HapticManager.shared.trigger(.longPress)
                    }
                    withAnimation(.smooth()) {
                        longPressInProgress = isPressing
                        if isPressing {
                            showVoiceOption = true
                        }
                    }

                    if !isPressing && showVoiceOption {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.smooth()) {
                                showVoiceOption = false
                            }
                        }
                    }
                },
                onDragUp: {
                    HapticManager.shared.trigger(.swipe)
                    withAnimation(.smooth()) {
                        willOpenCameraView = true
                        showVoiceOption = false
                        longPressInProgress = false
                    }
                }
            )

            Spacer()

            /// Expenses Tab
            TabButton(
                icon: "list.bullet",
                isSelected: selectedTab == .expenses
            ) {
                HapticManager.shared.trigger(.navigation)
                withAnimation(.smooth(duration: 0.2)) {
                    selectedTab = .expenses
                }
            }
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

// MARK: - Tab Button Component
private struct TabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Constraint.tinyPadding) {
                Image(systemName: icon)
                    .font(.system(size: Constraint.mediumIconSize, weight: .medium))
                    .foregroundStyle(
                        isSelected
                        ? .customWhiteSand
                        : .customWhiteSand.opacity(Constraint.Opacity.medium)
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                Circle()
                    .fill(.customWhiteSand)
                    .frame(width: Constraint.mediumSize, height: Constraint.mediumSize)
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected ? 1 : 0.5)
            }
            .frame(width: Constraint.extremeSize, height: Constraint.extremeSize)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Main Add Button Component
private struct MainAddButton: View {
    @Binding var showVoiceOption: Bool
    @Binding var longPressInProgress: Bool
    let onAddTap: () -> Void
    let onVoiceTap: () -> Void
    let onLongPress: (Bool) -> Void
    let onDragUp: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            /// Voice Recording Option Button
            if showVoiceOption {
                VStack(spacing: Constraint.smallPadding) {
                    CameraButton(action: onDragUp)
                        .offset(y: -2.5 * Constraint.extremeSize)
                    
                    VoiceButton(action: onVoiceTap)
                        .offset(y: -1.5 * Constraint.extremeSize)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                        removal: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.8))
                    )
                )
            }
            
            /// Main Add Button
            AddButton(
                isPressed: longPressInProgress,
                showVoiceOption: showVoiceOption,
                onAddTap: onAddTap
            )
            .offset(y: Constraint.mainButtonOffset)
            .onLongPressGesture(
                minimumDuration: 0.3,
                pressing: onLongPress,
                perform: {}
            )
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        if showVoiceOption && value.translation.height < -10 {
                            onDragUp()
                        }
                    }
            )
        }
    }
}

// MARK: - Voice Button Component
private struct VoiceButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Constraint.tinyPadding) {
                Image(systemName: "mic.fill")
                    .font(.system(size: Constraint.regularIconSize, weight: .medium))
                    .foregroundStyle(.customWhiteSand)
            }
            .padding(.horizontal, Constraint.padding)
            .padding(.vertical, Constraint.smallPadding)
            .background(
                Capsule()
                    .fill(.customGold)
                    .shadow(
                        color: .customRichBlack.opacity(Constraint.Opacity.low),
                        radius: Constraint.shadowRadius,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(VoiceButtonStyle())
    }
}

// MARK: - Camera Button Component
private struct CameraButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "camera.fill")
                .font(.system(size: Constraint.regularIconSize, weight: .medium))
                .foregroundStyle(.customWhiteSand)
        }
        .buttonStyle(CircularButtonStyle(
            backgroundColor: .customGold.opacity(0.8),
            size: Constraint.extremeSize,
            scale: 1.0
        ))
    }
}

// MARK: - Add Button Component
private struct AddButton: View {
    let isPressed: Bool
    let showVoiceOption: Bool
    let onAddTap: () -> Void

    var body: some View {
        Button { onAddTap() } label: {
            Image(systemName: "plus")
                .font(.system(size: Constraint.regularIconSize, weight: .semibold))
                .foregroundStyle(.customWhiteSand)
                .rotationEffect(.degrees(showVoiceOption ? 45 : 0))
        }
        .buttonStyle(CircularButtonStyle(
            backgroundColor: .customGold,
            size: Constraint.extremeSize,
            scale: showVoiceOption ? 1.1 : 1.0,
            opacity: Constraint.Opacity.visible
        ))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showVoiceOption)
    }
}

// MARK: - Voice Button Style
private struct VoiceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Circular Button Style
private struct CircularButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let size: CGFloat
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size, height: size)
                    .shadow(
                        color: .customRichBlack.opacity(Constraint.Opacity.low),
                        radius: Constraint.shadowRadius,
                        x: 0,
                        y: 0
                    )
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
