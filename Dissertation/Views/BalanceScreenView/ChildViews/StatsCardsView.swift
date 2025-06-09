import SwiftUI

// MARK: - Stats Cards View
struct StatsCardsView: View {
    var dailyBalance: Double
    var daysSinceEarliest: Int
    var opacity: CGFloat
    @Binding var showingAllowanceSheet: Bool

    var body: some View {
        HStack {
            /// Daily allowance Card
            DailyAllowanceCardView(
                dailyBalance: dailyBalance,
                opacity: opacity,
                showingAllowanceSheet: $showingAllowanceSheet
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

