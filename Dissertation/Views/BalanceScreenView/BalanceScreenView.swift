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

    var body: some View {
        VStack(alignment: .leading, spacing: Constraint.smallPadding) {
            /// Current Balance Card
            CurrentBalanceCardView(
                calculatedBalance: $calculatedBalance,
                opacity: Constraint.Opacity.medium
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
                opacity: Constraint.Opacity.medium,
                showingAllowanceSheet: $showingAllowanceSheet
            )

            /// Total Expenses Card
            TotalExpensesCardView(
                totalExpenses: totalExpenses,
                opacity: Constraint.Opacity.medium,
                expenses: $expenses,
                timeFrame: $timeFrame
            )
        }
        .padding(.horizontal, Constraint.padding)
//        .ignoresSafeArea()
//        .fixedSize(horizontal: false, vertical: true)
    }
}
