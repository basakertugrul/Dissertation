import SwiftUI
import SwiftData

// MARK: - Balance Screen View
struct BalanceScreenView: View {
    @EnvironmentObject var appState: AppStateManager
    @Binding var expenses: [ExpenseViewModel]
    @Binding var dailyBalance: Double
    @Binding var totalExpenses: Double
    @Binding var calculatedBalance: Double
    @State var timeFrame: TimeFrame
    @Binding var backgroundColor: Color
    @Binding var showingAllowanceSheet: Bool
    @Binding var currentTab: TabBarSection
    @Binding var startDay: Date
    
    var daySinceEarliest: Int {
        (Calendar.current.dateComponents([.day], from: startDay, to: Date()).day ?? 0) + 1
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: Constraint.padding) {
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
                    date: appState.startDate,
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
            .padding(Constraint.padding)
        }
        .frame(width: UIScreen.main.bounds.width)
        .gesture(
            DragGesture()
                .onChanged { _ in
                    HapticManager.shared.trigger(.light)
                }
        )
    }
}
