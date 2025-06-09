import SwiftUI

// MARK: - Current Balance Card View
struct CurrentBalanceCardView: View {
    @Binding var calculatedBalance: Double
    @State var opacity: CGFloat

    var body: some View {
        VStack(spacing: Constraint.smallPadding) {
            CustomTextView(
                calculatedBalance >= 0 ? "Available" : "Overdrawn",
                font: .bodySmall,
                color: .white.opacity(opacity),
                uppercase: true
            )

            CustomTextView.currency(abs(calculatedBalance), font: .titleLarge, color: .white)

            CustomTextView(
                calculatedBalance >= 0 ? "Crushing it!" : "Oops, went over!",
                font: .labelLarge,
                color: .customWhiteSand.opacity(opacity),
                uppercase: true
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
