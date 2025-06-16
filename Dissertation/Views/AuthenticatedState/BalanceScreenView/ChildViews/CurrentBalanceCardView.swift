import SwiftUI

// MARK: - Current Balance Card View
struct CurrentBalanceCardView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    
    @State private var animatedBalance: Double = 0
    @State private var showCard: Bool = false
    @State private var cardScale: CGFloat = 0.9
    @State private var cardOpacity: Double = 0.0
    @State private var statusOpacity: Double = 0.0
    @State private var balanceScale: CGFloat = 0.8
    @State private var motivationOffset: CGFloat = 20
    @State private var motivationOpacity: Double = 0.0
    @State private var circleScale: CGFloat = 0.5
    @State private var currentBackgroundColor: Color = .customOliveGreen
    
    private var backgroundColor: Color {
        appStateManager.calculatedBalance < 0 ? .customBurgundy : .customOliveGreen
    }
    private var statusText: String {
        appStateManager.calculatedBalance >= 0 ? "Available" : "Overdrawn"
    }
    private var motivationText: String {
        appStateManager.calculatedBalance >= 0 ? "Crushing it!" : "Oops, went over!"
    }
    private var balanceText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
            .string(from: NSNumber(value: animatedBalance)) ?? "£0"
    }

    var body: some View {
        VStack(spacing: Constraint.smallPadding) {
            HStack(spacing: Constraint.smallPadding) {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .scaleEffect(circleScale)
                CustomTextView(statusText.uppercased(), font: .labelLargeBold)
                    .opacity(statusOpacity)
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .scaleEffect(circleScale)
            }
            CustomTextView(balanceText, font: .titleLargeBold)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .scaleEffect(balanceScale)
                .opacity(cardOpacity)
            CustomTextView(motivationText, font: .labelLarge)
                .shadow(radius: Constraint.shadowRadius)
                .opacity(motivationOpacity)
                .offset(y: motivationOffset)
        }
        .addLayeredBackground(currentBackgroundColor, style: .banner)
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .onAppear {
            animateCardAppearance()
        }
        .onChange(of: appStateManager.calculatedBalance) { oldValue, newValue in
            if oldValue != newValue {
                animatedBalance = oldValue
                animateBalanceChange(from: oldValue, to: newValue)
            }
        }
    }

    private func animateCardAppearance() {
        // Set initial values
        currentBackgroundColor = backgroundColor

        // Sequential entrance animation
        withAnimation(.smooth(duration: 0.4)) {
            showCard = true
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        // Animate status with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.smooth()) {
                statusOpacity = 1.0
                circleScale = 1.0
            }
        }
        
        // Animate balance number
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.smooth()) {
                balanceScale = 1.0
            }
            // Animate the number counting up
            animateNumberCounting(to: appStateManager.calculatedBalance, duration: 0.8)
        }
        
        // Animate motivation text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.smooth(duration: 0.4)) {
                motivationOpacity = 1.0
                motivationOffset = 0
            }
        }
    }
    
    private func animateBalanceChange(from oldValue: Double, to newValue: Double) {
        let colorNeedsChange = (oldValue >= 0) != (newValue >= 0)
        
        // Animate number change with bounce
        withAnimation(.smooth()) {
            balanceScale = 1.15
        }
        
        // Animate number counting
        animateNumberCounting(to: newValue, duration: 0.6)
        
        // Scale back to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.smooth()) {
                balanceScale = 1.0
            }
        }
        
        // Animate background color change if needed
        if colorNeedsChange {
            withAnimation(.smooth(duration: 0.8, extraBounce: 0.1)) {
                currentBackgroundColor = backgroundColor
            }
        }
        
        // Animate status and motivation text
        withAnimation(.smooth()) {
            statusOpacity = 0.7
            motivationOpacity = 0.7
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.smooth(duration: 0.3)) {
                statusOpacity = 1.0
                motivationOpacity = 1.0
            }
        }
    }
    
    private func animateNumberCounting(to targetValue: Double, duration: Double) {
        let startValue = animatedBalance
        let difference = targetValue - startValue
        let steps = Int(duration * 60) // 60 FPS
        let increment = difference / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (duration / Double(steps)) * Double(i)) {
                animatedBalance = startValue + (increment * Double(i))
                
                // Ensure we end exactly at target
                if i == steps {
                    animatedBalance = targetValue
                }
            }
        }
    }
}
