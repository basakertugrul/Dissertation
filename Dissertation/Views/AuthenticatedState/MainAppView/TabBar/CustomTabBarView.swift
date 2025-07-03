import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabBarSection
    @Binding var showAddExpenseSheet: Bool
    @Binding var willOpenCameraView: Bool
    @Binding var willOpenVoiceRecording: Bool

    var body: some View {
        HStack(spacing: .zero) {
            /// Balance Tab
            TabButton(
                icon: "chart.bar.xaxis",
                isSelected: selectedTab == .balance
            ) {
                HapticManager.shared.trigger(.navigation)
                selectedTab = .balance
            }

            Spacer()

            /// Dynamic Add Button System
            MainButton(
                onAddTap: onTapAdd,
                onCameraTap: onTapCamera,
                onVoiceTap: onTapVoice
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
        .padding(.bottom, Constraint.largePadding)
        .background(
            Rectangle()
                .fill(.customRichBlack)
                .ignoresSafeArea()
        )
    }

    func onTapCamera() {
        HapticManager.shared.trigger(.buttonTap)
        willOpenCameraView = true
    }

    func onTapAdd() {
        HapticManager.shared.trigger(.buttonTap)
        showAddExpenseSheet = true
    }

    func onTapVoice() {
        HapticManager.shared.trigger(.buttonTap)
        willOpenVoiceRecording = true
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
