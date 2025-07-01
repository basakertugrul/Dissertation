import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: CustomTabBarSection
    @Binding var showAddExpenseSheet: Bool
    @State private var showOptions: Bool = false
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

            Spacer()

            /// Main Add Button
            MainAddButton(
                showOptions: $showOptions,
                onAddTap: {
                    HapticManager.shared.trigger(.add)
                    showAddExpenseSheet = true
                },
                onCameraTap: {
                    HapticManager.shared.trigger(.buttonTap)
                    willOpenCameraView = true
                    showOptions = false
                },
                onVoiceTap: {
                    HapticManager.shared.trigger(.buttonTap)
                    willOpenVoiceRecording = true
                    showOptions = false
                }
            )

            Spacer()

            /// Expenses Tab
            TabButton(
                icon: "list.bullet",
                isSelected: selectedTab == .expenses
            ) {
                HapticManager.shared.trigger(.navigation)
                selectedTab = .expenses
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

// MARK: - Extensions
extension CustomTabBar {
    
    // MARK: - Main Add Button
    struct MainAddButton: View {
        @Binding var showOptions: Bool
        let onAddTap: () -> Void
        let onCameraTap: () -> Void
        let onVoiceTap: () -> Void

        var body: some View {
            ZStack {
                // Options
                if showOptions {
                    VStack(spacing: Constraint.regularPadding) {
                        OptionButton(icon: "camera", action: onCameraTap)
                        OptionButton(icon: "waveform", action: onVoiceTap)
                    }
                    .offset(y: -3.5 * Constraint.extremeSize)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Main Button
                Button {
                    if showOptions {
                        HapticManager.shared.trigger(.buttonTap)
                        showOptions = false
                    } else {
                        HapticManager.shared.trigger(.add)
                        onAddTap()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: Constraint.regularIconSize, weight: .medium))
                        .foregroundStyle(.customWhiteSand)
                }
                .buttonStyle(MainButtonStyle(isExpanded: showOptions))
                .offset(y: Constraint.mainButtonOffset)
                .onLongPressGesture(minimumDuration: 0.3) {
                    HapticManager.shared.trigger(.longPress)
                    showOptions = true
                    
                    // Auto-hide after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showOptions = false
                        }
                    }
                }
            }
            .animation(.easeOut(duration: 0.25), value: showOptions)
        }
    }
    
    // MARK: - Option Button
    struct OptionButton: View {
        let icon: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: Constraint.regularIconSize, weight: .medium))
                    .foregroundStyle(.customWhiteSand)
                    .frame(width: Constraint.extremeSize, height: Constraint.extremeSize)
                    .background(
                        Circle()
                            .fill(.customGold)
                            .shadow(radius: 2, y: 1)
                    )
            }
            .buttonStyle(SoftButtonStyle())
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
struct MainButtonStyle: ButtonStyle {
    let isExpanded: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: Constraint.extremeSize, height: Constraint.extremeSize)
            .background(
                Circle()
                    .fill(.customGold)
                    .shadow(radius: isExpanded ? 4 : 2, y: isExpanded ? 2 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .scaleEffect(isExpanded ? 1.1 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
