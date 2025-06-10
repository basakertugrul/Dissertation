import SwiftUI

// MARK: - Expenses Screen
struct ExpensesScreenView: View {
    @Binding var expenses: [ExpenseViewModel]
    let onExpenseEdit: (ExpenseViewModel) -> Void

    private var groupedExpenses: [String: [ExpenseViewModel]] {
        Dictionary(grouping: expenses) { expense in
            /// Group by date
            if expense.isToday() {
                return "TODAY"
            } else if expense.isYesterday() {
                return "YESTERDAY"
            } else if expense.isInLastWeek() {
                return "THIS WEEK"
            } else if expense.isInLastMonth() {
                return "THIS MONTH"
            } else {
                return "EARLIER"
            }
        }
    }

    private var sortedKeys: [String] {
        let order = ["TODAY", "YESTERDAY", "THIS WEEK", "THIS MONTH", "EARLIER"]
        return groupedExpenses.keys.sorted { (key1, key2) in
            let index1 = order.firstIndex(of: key1) ?? Int.max
            let index2 = order.firstIndex(of: key2) ?? Int.max
            return index1 < index2
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constraint.smallPadding) {
                ForEach(sortedKeys, id: \.self) { key in
                    if let expensesForDate = groupedExpenses[key] {
                        VStack(alignment: .leading, spacing: Constraint.smallPadding) {
                            CustomTextView(
                                key,
                                font: .labelLarge,
                                color: Color.customRichBlack.opacity(Constraint.Opacity.medium)
                            )

                            ForEach(expensesForDate) { expense in
                                ExpenseItemView(expense: expense) {
                                    onExpenseEdit(expense)
                                }
                            }
                        }
                        .padding(.vertical, Constraint.tinyPadding)
                    }
                }
            }
            .padding(Constraint.padding)
        }
    }
}

// MARK: - Helper Views
struct ExpenseItemView: View {
    let expense: ExpenseViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                /// Name and date
                VStack(alignment: .leading, spacing: Constraint.tinyPadding) {
                    CustomTextView(expense.name, font: .bodySmall, color: .customWhiteSand)
                        .frame(height: 20)
                    CustomTextView(expense.getDateString(), font: .labelMedium, color: .customWhiteSand.opacity(Constraint.Opacity.high))
                }
                Spacer()
                /// Amount
                CustomTextView.currency(expense.amount, font: .bodySmallBold, color: .white)
            }
            .addLayeredBackground(
                with: .customGold,
                spacing: .compact,
                isRounded: true,
                isTheLineSameColorAsBackground: true
            )
        }
    }
}
