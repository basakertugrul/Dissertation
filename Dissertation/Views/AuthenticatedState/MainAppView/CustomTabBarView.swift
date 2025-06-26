import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: CustomTabBarSection
    @Binding var showAddExpenseSheet: Bool
    @State private var showCameraOption: Bool = false
    @State private var longPressInProgress: Bool = false
    @Binding var willOpenCameraView: Bool

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
                showCameraOption: $showCameraOption,
                longPressInProgress: $longPressInProgress,
                onAddTap: {
                    HapticManager.shared.trigger(.add)
                    withAnimation(.smooth) {
                        showAddExpenseSheet = true
                    }
                },
                onCameraTap: {
                    HapticManager.shared.trigger(.buttonTap)
                    withAnimation(.smooth()) {
                        willOpenCameraView = true
                        showCameraOption = false
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
                            showCameraOption = true
                        }
                    }

                    if !isPressing && showCameraOption {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.smooth()) {
                                showCameraOption = false
                            }
                        }
                    }
                },
                onDragCamera: {
                    HapticManager.shared.trigger(.swipe)
                    withAnimation(.smooth()) {
                        willOpenCameraView = true
                        showCameraOption = false
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
    @Binding var showCameraOption: Bool
    @Binding var longPressInProgress: Bool
    let onAddTap: () -> Void
    let onCameraTap: () -> Void
    let onLongPress: (Bool) -> Void
    let onDragCamera: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            /// Camera Option Button
            if showCameraOption {
                CameraButtonn(action: onCameraTap)
                    .offset(y: -1.75 * Constraint.extremeSize)
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
                showCameraOption: showCameraOption,
                onAddTap: onAddTap
            )
            .offset(y: Constraint.mainButtonOffset)
            .onLongPressGesture(
                minimumDuration: .leastNormalMagnitude,
                pressing: onLongPress,
                perform: {}
            )
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        if showCameraOption && value.translation.height < -10 {
                            onDragCamera()
                        }
                    }
            )
        }
    }
}

// MARK: - Camera Button Component
private struct CameraButtonn: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "camera")
                .font(.system(size: Constraint.regularIconSize, weight: .medium))
                .foregroundStyle(.customWhiteSand)
        }
        .buttonStyle(CircularButtonStyle(
            backgroundColor: .customGold,
            size: Constraint.extremeSize,
            scale: 1.3
        ))
    }
}

// MARK: - Add Button Component
private struct AddButton: View {
    let isPressed: Bool
    let showCameraOption: Bool
    let onAddTap: () -> Void

    var body: some View {
        Button { onAddTap() } label: {
            Image(systemName: "plus")
                .font(.system(size: Constraint.regularIconSize, weight: .semibold))
                .foregroundStyle(.customWhiteSand)
                .rotationEffect(.degrees(showCameraOption ? 90 : 0))
        }
        .buttonStyle(CircularButtonStyle(
            backgroundColor: .customGold,
            size: Constraint.extremeSize,
            scale: showCameraOption ? 1.25 : 1.0,
            opacity: Constraint.Opacity.visible
        ))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showCameraOption)
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
