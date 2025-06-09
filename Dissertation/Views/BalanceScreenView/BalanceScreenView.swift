import SwiftUI
import SwiftData

// MARK: - Balance Screen View
struct BalanceScreenView: View {
    @Binding var expenses: [ExpenseViewModel]
    @Binding var dailyBalance: Double
    @Binding var daysSinceEarliest: Int
    @Binding var totalExpenses: Double
    @Binding var calculatedBalance: Double
    @State var timeFrame: TimeFrame
    @Binding var backgroundColor: Color
    @Binding var showingAllowanceSheet: Bool
    @Binding var currentTab: CustomTabBarSection

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constraint.padding) {
                /// Current Balance Card
                CurrentBalanceCardView(
                    calculatedBalance: $calculatedBalance,
                    opacity: Constraint.Opacity.high
                )

                /// Divider
                DividerView()

                /// Budget Zones View
                BudgetZonesView(
                    expenses: $expenses,
                    totalBalance: $calculatedBalance,
                    timeFrame: $timeFrame,
                    dailyBalance: $dailyBalance,
                    backgroundColor: .init(get: {
                        backgroundColor == .customOliveGreen ? .customBurgundy : .customOliveGreen
                    }, set: { _ in } )
                )

                /// Stats Cards
                StatsCardsView(
                    dailyBalance: dailyBalance,
                    daysSinceEarliest: daysSinceEarliest,
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
