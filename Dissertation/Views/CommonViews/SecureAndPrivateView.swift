import SwiftUI

struct SecureAndPrivateView: View {
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: Constraint.tinyPadding) {
            CustomTextView("Secure & Private", font: .bodyLarge, color: .customWhiteSand)
            Button(action: onTap) {
                HStack(spacing: Constraint.smallPadding) {
                    CustomTextView("Terms", font: .labelSmallBold, color: .customWhiteSand)
                    Circle()
                        .fill(.customWhiteSand)
                        .frame(width: 4, height: 4)
                    CustomTextView("Privacy", font: .labelSmallBold, color: .customWhiteSand)
                    
                }
            }
        }
    }
}
