import SwiftUI

// MARK: - Animated Stats Cards View
struct StatsCardsView: View {
    var dailyBalance: Double
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
            
            /// Days Tracked Card
            DaysTrackedCardView(
                daysSinceEarliest: daysSinceEarliest,
                opacity: opacity
            )
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            .offset(x: cardTranslation)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            animateCardsAppearance()
        }
        .onChange(of: dailyBalance) { _, _ in
            animateContentUpdate()
        }
        .onChange(of: daysSinceEarliest) { _, _ in
            animateContentUpdate()
        }
    }
    
    private func animateCardsAppearance() {
        // Staggered entrance animation
        withAnimation(.smooth(duration: 0.4).delay(0.2)) {
            showCards = true
            cardScale = 1.0
            cardOpacity = 1.0
            cardTranslation = 0
        }
    }
    
    private func animateContentUpdate() {
        // Subtle bounce animation when content updates
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            cardScale = 1.05
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                cardScale = 1.0
            }
        }
    }
}
