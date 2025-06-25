import SwiftUI

// MARK: - Divider View
struct DividerView: View {
    var willAddSpacing: Bool = true

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .customRichBlack.opacity(Constraint.Opacity.high),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: Constraint.smallSize)
            .padding(.vertical, willAddSpacing ? Constraint.padding : .zero )
    }
}
