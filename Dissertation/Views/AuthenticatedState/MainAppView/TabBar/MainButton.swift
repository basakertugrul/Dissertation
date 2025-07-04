import SwiftUI

extension CustomTabBar {
    struct MainButton: View {
        let onAddTap: () -> Void
        let onCameraTap: () -> Void
        let onVoiceTap: () -> Void
        
        var body: some View {
            IntegratedGestureButtonView(
                onMainTap: onAddTap,
                onCameraTap: onCameraTap,
                onVoiceTap: onVoiceTap
            )
        }
    }
    
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
            .shadow(color: .customRichBlack.opacity(Constraint.Opacity.high), radius: Constraint.shadowRadius)
        }
    }
}

struct IntegratedGestureButtonView: View {
    let onMainTap: () -> Void
    let onCameraTap: () -> Void
    let onVoiceTap: () -> Void
    
    @State private var selectedButton: Int? = nil
    @State private var showAdditionalButtons = false
    @State private var cameraButtonOffset: CGSize = .zero
    @State private var voiceButtonOffset: CGSize = .zero
    @State private var buttonScale: CGFloat = 0.1
    @State private var buttonOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            AppMainButton(
                index: 2,
                selectedIndex: selectedButton,
                action: {
                    if showAdditionalButtons {
                        onMainTap()
                        hideButtons()
                    } else {
                        showButtons()
                    }
                }
            )

            if showAdditionalButtons {
                AppFloatingButton(
                    index: 0,
                    selectedIndex: selectedButton,
                    icon: "camera.fill",
                    backgroundColor: .customGold,
                    action: {
                        onCameraTap()
                        hideButtons()
                    }
                )
                .scaleEffect(buttonScale)
                .opacity(buttonOpacity)
                .offset(cameraButtonOffset)
            }

            if showAdditionalButtons {
                AppFloatingButton(
                    index: 1,
                    selectedIndex: selectedButton,
                    icon: "waveform",
                    backgroundColor: .customGold,
                    action: {
                        onVoiceTap()
                        hideButtons()
                    }
                )
                .scaleEffect(buttonScale)
                .opacity(buttonOpacity)
                .offset(voiceButtonOffset)
            }
        }
        .simultaneousGesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { value in
                    if showAdditionalButtons {
                        updateSelectedButton(at: value.location)

                        if !isLocationInButtonArea(value.location) {
                            selectedButton = nil
                            hideButtons()
                        }
                    }
                }
                .onEnded { value in
                    if let selected = selectedButton, showAdditionalButtons {
                        performAction(for: selected)
                        hideButtons()
                    }
                    selectedButton = nil
                }
        )
    }
    
    private func showButtons() {
        showAdditionalButtons = true
        HapticManager.shared.trigger(.heavy)

        withAnimation(.smooth) {
            cameraButtonOffset = CGSize(width: -15, height: -(Constraint.extremeSize - Constraint.largePadding + 20))
            voiceButtonOffset = CGSize(width: 15, height: -(Constraint.extremeSize - Constraint.largePadding + 20))
            buttonScale = 0.8
            buttonOpacity = 0.8
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.smooth) {
                cameraButtonOffset = CGSize(width: -70, height: -130)
                voiceButtonOffset = CGSize(width: 70, height: -130)
                buttonScale = 1.1
                buttonOpacity = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.smooth) {
                cameraButtonOffset = CGSize(width: -60, height: -120)
                voiceButtonOffset = CGSize(width: 60, height: -120)
                buttonScale = 1.2
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hideButtons()
        }
    }
    
    private func hideButtons() {
        withAnimation(.smooth) {
            cameraButtonOffset = CGSize(width: -20, height: -60)
            voiceButtonOffset = CGSize(width: 20, height: -60)
            buttonScale = 0.6
            buttonOpacity = 0.7
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.smooth) {
                cameraButtonOffset = CGSize(width: -5, height: -(Constraint.extremeSize - Constraint.largePadding + 5))
                voiceButtonOffset = CGSize(width: 5, height: -(Constraint.extremeSize - Constraint.largePadding + 5))
                buttonScale = 0.3
                buttonOpacity = 0.3
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.smooth) {
                cameraButtonOffset = CGSize(width: 0, height: -(Constraint.extremeSize - Constraint.largePadding))
                voiceButtonOffset = CGSize(width: 0, height: -(Constraint.extremeSize - Constraint.largePadding))
                buttonScale = 0.1
                buttonOpacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showAdditionalButtons = false
        }
        
        selectedButton = nil
    }
    
    private func isLocationInButtonArea(_ location: CGPoint) -> Bool {
        let buttonAreaHeight: CGFloat = showAdditionalButtons ? 200 : 100
        let buttonAreaWidth: CGFloat = 250
        
        let expandedArea = CGRect(
            x: -50,
            y: -50,
            width: buttonAreaWidth,
            height: buttonAreaHeight
        )
        return expandedArea.contains(location)
    }
    
    private func updateSelectedButton(at location: CGPoint) {
        guard showAdditionalButtons else { return }
        
        let buttonRadius: CGFloat = 50
        let centerButtonX: CGFloat = 100
        let mainButtonY: CGFloat = 75
        let leftButtonX: CGFloat = 40
        let rightButtonX: CGFloat = 160
        let topButtonY: CGFloat = -45
        
        let distanceToCamera = sqrt(pow(location.x - leftButtonX, 2) + pow(location.y - topButtonY, 2))
        let distanceToVoice = sqrt(pow(location.x - rightButtonX, 2) + pow(location.y - topButtonY, 2))
        let distanceToMain = sqrt(pow(location.x - centerButtonX, 2) + pow(location.y - mainButtonY, 2))
        
        let minDistance = min(distanceToCamera, distanceToVoice, distanceToMain)
        
        if minDistance < buttonRadius {
            if distanceToCamera == minDistance {
                selectedButton = 0
            } else if distanceToVoice == minDistance {
                selectedButton = 1
            } else if distanceToMain == minDistance {
                selectedButton = 2
            }
        } else {
            selectedButton = nil
        }
    }
    
    private func performAction(for buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            onCameraTap()
        case 1:
            onVoiceTap()
        case 2:
            onMainTap()
        default:
            break
        }
    }
}

struct AppFloatingButton: View {
    let index: Int
    let selectedIndex: Int?
    let icon: String
    let backgroundColor: Color
    let action: () -> Void

    private var isSelected: Bool {
        selectedIndex == index
    }

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(backgroundColor)
                .frame(width: Constraint.extremeSize, height: Constraint.extremeSize)
                .shadow(color: .customRichBlack.opacity(Constraint.Opacity.high), radius: Constraint.shadowRadius)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: Constraint.regularIconSize, weight: .medium))
                        .foregroundStyle(.customWhiteSand)
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.customGold.opacity(0.9), backgroundColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 3 : 0
                        )
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                )
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.smooth, value: isSelected)
        }
        .buttonStyle(ElasticButtonStyle())
        .shadow(color: .customRichBlack.opacity(Constraint.Opacity.high), radius: Constraint.shadowRadius)
    }
}

struct AppMainButton: View {
    let index: Int
    let selectedIndex: Int?
    let action: () -> Void
    
    private var isSelected: Bool {
        selectedIndex == index
    }
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(.customGold)
                .frame(width: Constraint.extremeSize, height: Constraint.extremeSize)
                .shadow(color: .customRichBlack.opacity(Constraint.Opacity.high), radius: Constraint.shadowRadius)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: Constraint.regularIconSize, weight: .bold))
                        .foregroundStyle(.customWhiteSand)
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.customWhiteSand.opacity(0.8), .customGold.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 3 : 0
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                )
                .scaleEffect(isSelected ? 1.2 : 1.08)
                .animation(.smooth, value: isSelected)
        }
        .buttonStyle(ElasticButtonStyle())
        .offset(y: -(Constraint.extremeSize - Constraint.largePadding))
    }
}
