import SwiftUI

// MARK: - Daily Allowance Card View
struct DailyAllowanceCardView: View {
    var dailyBalance: Double
    var opacity: CGFloat
    @Binding var showingAllowanceSheet: Bool
    @Binding var backgroundColor: Color

    var body: some View {
        Button(action: {
            withAnimation {
                self.showingAllowanceSheet = true
            }
        }) {
            VStack(alignment: .leading, spacing: Constraint.regularPadding) {
                CustomTextView(
                    "Daily limit",
                    font: .labelMedium,
                    color: .customWhiteSand.opacity(opacity),
                    uppercase: true
                )

                HStack {
                    CustomTextView.currency(dailyBalance, font: .titleSmallBold, color: .white)

                    Spacer()

                    /// Edit button
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: Constraint.mediumIconSize, height: Constraint.mediumIconSize)
                        .overlay(
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: Constraint.mediumIconSize * 1/2, height: Constraint.mediumIconSize * 1/2)
                                .foregroundColor(.customWhiteSand.opacity(opacity))
                        )
                }
            }
            .addLayeredBackground(.customRichBlack.opacity(opacity), style: .card())
        }
    }
}
