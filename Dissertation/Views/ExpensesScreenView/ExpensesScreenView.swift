import SwiftUI

// MARK: - Expenses Screen
struct ExpensesScreenView: View {
    @Binding var expenses: [ExpenseViewModel]
    let onExpenseEdit: (ExpenseViewModel) -> Void

    private var groupedExpenses: [String: [ExpenseViewModel]] {
        Dictionary(grouping: expenses) { expense in
            /// Group by date
            let dateFormatter = DateFormatter()
            let calendar = Calendar(identifier: .iso8601)
            dateFormatter.dateFormat = "yyyy-MM-dd"

            if calendar.isDateInToday(expense.date) {
                return "TODAY"
            } else if calendar.isDateInYesterday(expense.date) {
                return "YESTERDAY"
            } else if calendar.isDate(expense.date, equalTo: Date(), toGranularity: .weekOfYear) {
                return "THIS WEEK"
            } else if calendar.isDate(expense.date, equalTo: Date(), toGranularity: .month) {
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
                                color: Color.customWhiteSand.opacity(Constraint.Opacity.medium)
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
                /// Name
                CustomTextView(expense.name, font: .bodySmall)

                Spacer()

                /// Amount and date
                VStack(alignment: .trailing, spacing: Constraint.tinyPadding) {
                    CustomTextView("£" + String(format: "%.2f", expense.amount), font: .bodySmallBold)

                    CustomTextView(expense.getDateString(), font: .labelMedium, color: .customWhiteSand.opacity(Constraint.Opacity.medium))
                }
            }
            .padding(.vertical, Constraint.smallPadding)
            .padding(.horizontal, Constraint.padding)
            .background(.customRichBlack.opacity(Constraint.Opacity.low))
            .cornerRadius(Constraint.regularCornerRadius)
            .buttonStyle(.bordered)
        }
    }
}
