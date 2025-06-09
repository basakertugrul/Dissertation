import SwiftUI

// MARK: - Divider View

struct DividerView: View {
    var willAddSpacing: Bool = true

    var body: some View {
        Rectangle()
            .fill(.customWhiteSand.opacity(Constraint.Opacity.medium))
            .frame(height: Constraint.smallSize)
            .padding(
                .vertical,
                willAddSpacing ? Constraint.padding : .zero
            )
    }
}
