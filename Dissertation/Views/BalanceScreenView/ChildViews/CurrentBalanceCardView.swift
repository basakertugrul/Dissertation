import SwiftUI

// MARK: - Current Balance Card View
struct CurrentBalanceCardView: View {
    @Binding var calculatedBalance: Double
    @State var opacity: CGFloat

    var body: some View {
        VStack(spacing: Constraint.padding) {
            CustomTextView(
                calculatedBalance >= 0 ? "Available" : "Overdrawn",
                font: .bodySmall,
                color: .customWhiteSand.opacity(opacity),
                uppercase: true
            )

            CustomTextView.currency(abs(calculatedBalance), font: .titleLarge, color: .customWhiteSand)

            CustomTextView(
                calculatedBalance >= 0 ? "Within Budget" : "Over Budget",
                font: .labelLarge,
                color: .customWhiteSand.opacity(opacity),
                uppercase: true
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
