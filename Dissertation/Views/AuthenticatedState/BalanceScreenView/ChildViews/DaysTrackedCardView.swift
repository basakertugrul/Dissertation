import SwiftUI
// MARK: - Days Tracked Card View
struct DaysTrackedCardView: View {
    var date: Date
    var daysSinceEarliest: Int
    var opacity: CGFloat
    
    @State private var isPressed: Bool = false
    @State private var cardScale: CGFloat = 1.0
    @State private var numberScale: CGFloat = 1.0
    @State private var showPulse: Bool = false
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date).lowercased()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constraint.regularPadding) {
            CustomTextView(
                NSLocalizedString("days_tracked", comment: ""),
                font: .labelMedium,
                color: .customWhiteSand.opacity(opacity),
                uppercase: true
            )
            
            HStack(alignment: .firstTextBaseline) {
                CustomTextView(
                    "\(daysSinceEarliest)",
                    font: .titleSmall,
                    color: .white,
                    isBold: true
                )
                .scaleEffect(numberScale)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .scaleEffect(showPulse ? 1.5 : 0.8)
                        .opacity(showPulse ? 0 : 0.3)
                        .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: showPulse)
                )
                
                CustomTextView(
                    "\(NSLocalizedString("since", comment: "")) \(formattedDate)",
                    font: .labelSmall,
                    color: .customWhiteSand.opacity(opacity)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addLayeredBackground(.customRichBlack.opacity(Constraint.Opacity.high), style: .card())
        .scaleEffect(cardScale)
        .onTapGesture {
            HapticManager.shared.trigger(.selection)
            animateTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            HapticManager.shared.trigger(.longPress)
            animateLongPress()
        }
        .onAppear {
            HapticManager.shared.trigger(.light)
            animateAppearance()
        }
        .onChange(of: daysSinceEarliest) { oldValue, newValue in
            if oldValue != newValue {
                HapticManager.shared.trigger(.notification)
                animateNumberUpdate()
            }
        }
    }
    
    private func animateTap() {
        withAnimation(.easeInOut(duration: 0.1)) {
            cardScale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.2)) {
                cardScale = 1.0
            }
        }
    }
    
    private func animateLongPress() {
        withAnimation(.easeInOut(duration: 0.2)) {
            cardScale = 0.9
            numberScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) {
                cardScale = 1.0
                numberScale = 1.0
            }
        }
    }
    
    private func animateAppearance() {
        // Subtle pulse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showPulse = true
        }
    }
    
    private func animateNumberUpdate() {
        // Celebratory animation for new day
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            numberScale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) {
                numberScale = 1.0
            }
        }
        
        // Brief pulse effect
        showPulse = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showPulse = true
        }
    }
}
