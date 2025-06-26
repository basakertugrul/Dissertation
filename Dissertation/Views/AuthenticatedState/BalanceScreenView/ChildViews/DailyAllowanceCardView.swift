import SwiftUI

// MARK: - Daily Allowance Card View
struct DailyAllowanceCardView: View {
    var dailyBalance: Double
    var opacity: CGFloat
    @Binding var showingAllowanceSheet: Bool
    @Binding var backgroundColor: Color

    @State private var cardScale: CGFloat = 1.0
    @State private var editButtonScale: CGFloat = 1.0
    @State private var editButtonRotation: Double = 0

    var body: some View {
        Button(action: {
            HapticManager.shared.trigger(.buttonTap)
            animateButtonPress()
            withAnimation {
                self.showingAllowanceSheet = true
            }
        }) {
            VStack(alignment: .leading, spacing: Constraint.regularPadding) {
                CustomTextView(
                    "Daily limit",
                    font: .labelMedium,
                    color: .customWhiteSand.opacity(opacity),
                    uppercase: true
                )

                HStack {
                    CustomTextView.currency(dailyBalance, font: .titleSmallBold, color: .white)

                    Spacer()

                    /// Edit button
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: Constraint.mediumIconSize, height: Constraint.mediumIconSize)
                        .overlay(
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: Constraint.mediumIconSize * 1/2, height: Constraint.mediumIconSize * 1/2)
                                .foregroundColor(.customWhiteSand.opacity(opacity))
                                .rotationEffect(.degrees(editButtonRotation))
                        )
                        .scaleEffect(editButtonScale)
                }
            }
            .addLayeredBackground(.customRichBlack.opacity(opacity), style: .card())
        }
        .scaleEffect(cardScale)
        .onLongPressGesture(minimumDuration: 0.0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                cardScale = pressing ? 0.95 : 1.0
            }
            if pressing {
                HapticManager.shared.trigger(.light)
            }
        }, perform: {
            HapticManager.shared.trigger(.longPress)
        })
        .onChange(of: dailyBalance) { oldValue, newValue in
            if oldValue != newValue {
                if newValue > oldValue {
                    HapticManager.shared.trigger(.success)
                } else if newValue < oldValue {
                    HapticManager.shared.trigger(.warning)
                } else {
                    HapticManager.shared.trigger(.light)
                }
            }
        }
        .onChange(of: backgroundColor) { _, _ in
            HapticManager.shared.trigger(.selection)
            animateBackgroundChange()
        }
    }
    
    private func animateButtonPress() {
        withAnimation(.easeInOut(duration: 0.1)) {
            cardScale = 0.95
            editButtonScale = 0.9
            editButtonRotation = 15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cardScale = 1.0
                editButtonScale = 1.0
                editButtonRotation = 0
            }
        }
    }
    
    private func animateBackgroundChange() {
        withAnimation(.easeInOut(duration: 0.3)) {
            editButtonRotation = 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                editButtonRotation = 0
            }
        }
    }
}
