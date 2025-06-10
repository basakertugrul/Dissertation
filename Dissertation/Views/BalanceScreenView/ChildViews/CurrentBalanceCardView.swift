import SwiftUI

// MARK: - Current Balance Card View
struct CurrentBalanceCardView: View {
    @Binding var calculatedBalance: Double
    @Binding var backgrounColor: Color

    var body: some View {
        VStack(spacing: Constraint.smallPadding) {
            CustomTextView(
                calculatedBalance >= 0 ? "Available" : "Overdrawn",
                font: .bodySmall,
                color: .white.opacity(Constraint.Opacity.high),
                uppercase: true
            )

            CustomTextView.currency(abs(calculatedBalance), font: .titleLarge, color: .white)

            CustomTextView(
                calculatedBalance >= 0 ? "Crushing it!" : "Oops, went over!",
                font: .labelLarge,
                color: .customWhiteSand.opacity(Constraint.Opacity.high),
                uppercase: true
            )
        }
        .addLayeredBackground(
            with: backgrounColor,
            expandFullWidth: true,
            keepTheColor: true
        )
       
    }
}
