import SwiftUI

// MARK: - Stats Cards View
struct StatsCardsView: View {
    var dailyBalance: Double
    var daysSinceEarliest: Int
    var opacity: CGFloat
    @Binding var showingAllowanceSheet: Bool
    @Binding var backgroundColor: Color

    var body: some View {
        HStack {
            /// Daily allowance Card
            DailyAllowanceCardView(
                dailyBalance: dailyBalance,
                opacity: opacity,
                showingAllowanceSheet: $showingAllowanceSheet,
                backgroundColor: $backgroundColor
            )
            
            /// Days Tracked Card
            DaysTrackedCardView(
                daysSinceEarliest: daysSinceEarliest,
                opacity: opacity
            )
        }
        .frame(maxWidth: .infinity)
    }
}

