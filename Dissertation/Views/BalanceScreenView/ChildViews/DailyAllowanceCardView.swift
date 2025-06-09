import SwiftUI

// MARK: - Daily Allowance Card View
struct DailyAllowanceCardView: View {
    var dailyBalance: Double
    var opacity: CGFloat
    @Binding var showingAllowanceSheet: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                self.showingAllowanceSheet = true
            }
        }) {
            VStack(alignment: .leading, spacing: Constraint.padding) {
                CustomTextView(
                    "Daily Allowance",
                    font: .labelMedium,
                    color: .customWhiteSand.opacity(opacity),
                    uppercase: true
                )

                HStack {
                    CustomTextView.currency(dailyBalance, font: .titleSmall, color: .white)

                    Spacer()

                    /// Edit button
                    Circle()
                        .fill(.customBurgundy.opacity(Constraint.Opacity.medium))
                        .frame(width: Constraint.mediumIconSize, height: Constraint.mediumIconSize)
                        .overlay(
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: Constraint.mediumIconSize * 1/2, height: Constraint.mediumIconSize * 1/2)
                                .foregroundColor(.customWhiteSand.opacity(Constraint.Opacity.high))
                        )
                }
            }
            .addLayeredBackground(with: .customRichBlack.opacity(Constraint.Opacity.high))
        }
    }
}
