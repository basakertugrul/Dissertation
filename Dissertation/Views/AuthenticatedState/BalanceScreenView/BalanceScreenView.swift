import SwiftUI
import SwiftData

// MARK: - Balance Screen View
struct BalanceScreenView: View {
    @Binding var expenses: [ExpenseViewModel]
    @Binding var dailyBalance: Double
    @Binding var totalExpenses: Double
    @Binding var calculatedBalance: Double
    @State var timeFrame: TimeFrame
    @Binding var backgroundColor: Color
    @Binding var showingAllowanceSheet: Bool
    @Binding var currentTab: CustomTabBarSection
    @Binding var startDay: Date
    
    var daySinceEarliest: Int {
        (Calendar.current.dateComponents([.day], from: startDay, to: Date()).day ?? 0) + 1
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constraint.padding) {
                /// Current Balance Card
                CurrentBalanceCardView()

                /// Budget Zones View
                BudgetZonesView(
                    expenses: $expenses,
                    totalBalance: $calculatedBalance,
                    timeFrame: $timeFrame,
                    dailyBalance: $dailyBalance,
                    startDay: $startDay
                )

                /// Stats Cards
                StatsCardsView(
                    dailyBalance: dailyBalance,
                    daysSinceEarliest: daySinceEarliest,
                    opacity: Constraint.Opacity.high,
                    showingAllowanceSheet: $showingAllowanceSheet,
                    backgroundColor: $backgroundColor
                )

                /// Total Expenses Card
                TotalExpensesCardView(
                    totalExpenses: totalExpenses,
                    opacity: Constraint.Opacity.high,
                    expenses: $expenses,
                    timeFrame: $timeFrame,
                    backgroundColor: $backgroundColor,
                    currentTab: $currentTab
                )
            }
            .padding(.horizontal, Constraint.padding)
        }
        .ignoresSafeArea()
    }
}
