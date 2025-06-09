import SwiftUI

// MARK: - Days Tracked Card View
struct DaysTrackedCardView: View {
    var daysSinceEarliest: Int
    var opacity: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constraint.padding) {
            CustomTextView(
                "Days Tracked",
                font: .labelMedium,
                color: .customWhiteSand.opacity(opacity),
                uppercase: true
            )
            
            HStack(alignment: .firstTextBaseline) {
                CustomTextView(
                    "\(daysSinceEarliest)",
                    font: .titleSmall,
                    color: .white,
                    isBold: true
                )
                
                CustomTextView(
                    "since May 2",
                    font: .labelSmall,
                    color: .customWhiteSand.opacity(opacity)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .addLayeredBackground(with: .customRichBlack.opacity(Constraint.Opacity.high))
    }
}
