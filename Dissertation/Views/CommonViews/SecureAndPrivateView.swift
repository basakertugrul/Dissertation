import SwiftUI

struct SecureAndPrivateView: View {
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: Constraint.tinyPadding) {
            CustomTextView(NSLocalizedString("secure_private", comment: ""), font: .bodyLarge, color: .customWhiteSand)
            Button(action: onTap) {
                HStack(spacing: Constraint.smallPadding) {
                    CustomTextView(NSLocalizedString("terms", comment: ""), font: .labelSmallBold, color: .customWhiteSand)
                    Circle()
                        .fill(.customWhiteSand)
                        .frame(width: 4, height: 4)
                    CustomTextView(NSLocalizedString("privacy", comment: ""), font: .labelSmallBold, color: .customWhiteSand)
                    
                }
            }
        }
    }
}
