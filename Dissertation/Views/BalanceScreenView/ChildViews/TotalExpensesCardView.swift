import SwiftUI

// MARK: - Total Expenses Card View
struct TotalExpensesCardView: View {
    var totalExpenses: Double
    var opacity: CGFloat
    @Binding var expenses: [ExpenseViewModel]
    @Binding var timeFrame: TimeFrame

    var body: some View {
        HStack(spacing: Constraint.smallPadding) {
            Circle()
                .fill(.customOliveGreen.opacity(Constraint.Opacity.medium))
                .frame(width: Constraint.largeIconSize, height: Constraint.largeIconSize)
                .overlay(
                    Image(systemName: "target")
                        .frame(width: Constraint.mediumIconSize, height: Constraint.mediumIconSize)
                        .foregroundColor(.customWhiteSand)
                )

                CustomTextView(
                    "Total Expenses",
                    font: .labelMedium,
                    color: .customWhiteSand.opacity(opacity),
                    uppercase: true
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                CustomTextView.currency(totalExpenses, font: .titleSmall, color: .white)
        }
        .addLayeredBackground(with: .customRichBlack.opacity(Constraint.Opacity.high))
        
    }
}
