import SwiftUI

// MARK: - Animated Stats Cards View
struct StatsCardsView: View {
    var dailyBalance: Double
    var date: Date
    var daysSinceEarliest: Int
    var opacity: CGFloat
    @Binding var showingAllowanceSheet: Bool
    @Binding var backgroundColor: Color
    
    @State private var showCards: Bool = false
    @State private var cardScale: CGFloat = 0.9
    @State private var cardOpacity: Double = 0.0
    @State private var cardTranslation: CGFloat = 30
    
    var body: some View {
        HStack {
            /// Daily allowance Card
            DailyAllowanceCardView(
                dailyBalance: dailyBalance,
                opacity: opacity,
                showingAllowanceSheet: $showingAllowanceSheet,
                backgroundColor: $backgroundColor
            )
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            .offset(x: -cardTranslation)
            .onTapGesture {
                HapticManager.shared.trigger(.buttonTap)
                showingAllowanceSheet = true
            }
            .onLongPressGesture {
                HapticManager.shared.trigger(.longPress)
            }
            
            /// Days Tracked Card
            DaysTrackedCardView(
                date: date,
                daysSinceEarliest: daysSinceEarliest,
                opacity: opacity
            )
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            .offset(x: cardTranslation)
            .onTapGesture {
                HapticManager.shared.trigger(.light)
            }
            .onLongPressGesture {
                HapticManager.shared.trigger(.medium)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            animateCardsAppearance()
        }
        .onChange(of: dailyBalance) { oldValue, newValue in
            if oldValue != newValue {
                // Provide contextual haptic feedback based on balance change
                if newValue > oldValue {
                    HapticManager.shared.trigger(.success)
                } else if newValue < oldValue {
                    HapticManager.shared.trigger(.warning)
                } else {
                    HapticManager.shared.trigger(.light)
                }
                animateContentUpdate()
            }
        }
        .onChange(of: daysSinceEarliest) { oldValue, newValue in
            if oldValue != newValue {
                HapticManager.shared.trigger(.notification)
                animateContentUpdate()
            }
        }
    }
    
    private func animateCardsAppearance() {
        // Staggered entrance animation with haptic feedback
        HapticManager.shared.trigger(.light)
        
        withAnimation(.smooth(duration: 0.4).delay(0.2)) {
            showCards = true
            cardScale = 1.0
            cardOpacity = 1.0
            cardTranslation = 0
        }
    }
    
    private func animateContentUpdate() {
        // Subtle bounce animation when content updates
        withAnimation(.smooth()) {
            cardScale = 1.05
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.smooth()) {
                cardScale = 1.0
            }
        }
    }
}
