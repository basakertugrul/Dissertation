import SwiftUI

// MARK: - Total Expenses Card View
struct TotalExpensesCardView: View {
    var totalExpenses: Double
    var opacity: CGFloat
    @Binding var expenses: [ExpenseViewModel]
    @Binding var timeFrame: TimeFrame
    @Binding var backgroundColor: Color
    @Binding var currentTab: CustomTabBarSection
    
    @State private var showCard: Bool = false
    @State private var cardScale: CGFloat = 0.95
    @State private var cardOpacity: Double = 0.0
    @State private var iconRotation: Double = 0
    @State private var iconScale: CGFloat = 0.8
    @State private var numberScale: CGFloat = 0.9
    @State private var textOffset: CGFloat = -20
    @State private var numberOffset: CGFloat = 20
    
    var body: some View {
        HStack(spacing: Constraint.smallPadding) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    currentTab = .expenses
                }
                animateButtonPress()
            } label: {
                Circle()
                    .fill(backgroundColor == .customBurgundy
                          ? .customOliveGreen
                          : .customBurgundy
                    )
                    .frame(width: Constraint.largeIconSize, height: Constraint.largeIconSize)
                    .overlay(
                        Image(systemName: "target")
                            .frame(width: Constraint.mediumIconSize, height: Constraint.mediumIconSize)
                            .foregroundColor(.customWhiteSand)
                            .scaleEffect(iconScale)
                            .rotationEffect(.degrees(iconRotation))
                    )
                    .scaleEffect(showCard ? 1.0 : 0.8)
            }
            .buttonStyle(PlainButtonStyle())

            CustomTextView(
                "Total Expenses",
                font: .labelMedium,
                color: .customWhiteSand.opacity(opacity),
                uppercase: true
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(cardOpacity)
            .offset(x: textOffset)
            
            CustomTextView.currency(totalExpenses, font: .titleSmall, color: .white)
                .scaleEffect(numberScale)
                .opacity(cardOpacity)
                .offset(x: numberOffset)
        }
        .addLayeredBackground(with: .customRichBlack.opacity(opacity))
        .scaleEffect(cardScale)
        .onAppear {
            animateCardAppearance()
        }
        .onChange(of: totalExpenses) { _, _ in
            animateNumberUpdate()
        }
        .onChange(of: expenses) { _, _ in
            animateContentUpdate()
        }
        .onChange(of: timeFrame) { _, _ in
            animateContentUpdate()
        }
    }
    
    private func animateCardAppearance() {
        // Sequential entrance animation
        withAnimation(.smooth(duration: 0.3).delay(0.3)) {
            showCard = true
            cardScale = 1.0
            cardOpacity = 1.0
            textOffset = 0
            numberOffset = 0
        }
        
        // Icon animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
        }
        
        // Number animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                numberScale = 1.0
            }
        }
    }
    
    private func animateButtonPress() {
        // Button press feedback
        withAnimation(.easeInOut(duration: 0.1)) {
            iconScale = 0.9
            iconRotation = 15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                iconScale = 1.0
                iconRotation = 0
            }
        }
    }
    
    private func animateNumberUpdate() {
        // Animate number changes
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            numberScale = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                numberScale = 1.0
            }
        }
    }
    
    private func animateContentUpdate() {
        // Subtle card update animation
        withAnimation(.smooth(duration: 0.2)) {
            cardScale = 0.98
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                cardScale = 1.0
            }
        }
    }
}
