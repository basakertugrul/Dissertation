import SwiftUI

struct SecureAndPrivateView: View {
    let handleTermsTap: () -> Void
    let handlePrivacyTap: () -> Void

    var body: some View {
        VStack(spacing: Constraint.tinyPadding) {
            CustomTextView("Secure & Private", font: .bodyLarge, color: .customWhiteSand)
            HStack(spacing: Constraint.smallPadding) {
                Button(action: handleTermsTap) {
                    CustomTextView("Terms", font: .labelSmallBold, color: .customWhiteSand)
                }
                Circle()
                    .fill(.customWhiteSand)
                    .frame(width: 4, height: 4)
                Button(action: handlePrivacyTap) {
                    CustomTextView("Privacy", font: .labelSmallBold, color: .customWhiteSand)
                }
            }
        }
    }
}
