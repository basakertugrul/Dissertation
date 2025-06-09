import SwiftUI

// MARK: - View Extension for Layered Background
extension View {
    func addLayeredBackground(
        with color: Color,
        expandFullWidth: Bool = true,
        spacing: ContentSpacing = .regular,
        isRounded: Bool = false,
        layerWeight: LayerWeight = .heavy,
        isTheLineSameColorAsBackground: Bool = false,
        keepTheColor: Bool = false
    ) -> some View {
        let cornerRadius: CGFloat = switch (isRounded, spacing) {
        case (true, .compact): Constraint.cornerRadius
        case (true, .regular): Constraint.cornerRadius * 2
        case (false, .compact): Constraint.smallCornerRadius
        case (false, .regular): Constraint.cornerRadius
        }
        return self
            .padding(spacing.padding)
            .frame(maxWidth: expandFullWidth ? .infinity : .none)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: color.opacity(keepTheColor ? 1.0 : 0.8), location: 0.0),
                                .init(color: color.opacity(keepTheColor ? 1.0 : 0.4), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(isTheLineSameColorAsBackground
                                    ? color.opacity(Constraint.Opacity.low)
                                    : .customWhiteSand.opacity(Constraint.Opacity.low),
                                    lineWidth: 1.5)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial.opacity(keepTheColor ? 0 : 1))
                            .environment(\.colorScheme, .dark)
                    )
                    .shadow(
                        color: .customRichBlack.opacity(Constraint.Opacity.low),
                        radius: Constraint.shadowRadius,
                        x: 0,
                        y: 5
                    )
            )
    }
}

// MARK: - Layer Weight Configuration
enum LayerWeight {
    case light
    case medium
    case heavy
    
    func getValue() -> Double {
        switch self {
        case .light: return Constraint.LayerWeight.light
        case .medium: return Constraint.LayerWeight.medium
        case .heavy: return Constraint.LayerWeight.heavy
        }
    }
}

// MARK: - Content Spacing Configuration
enum ContentSpacing {
    case compact
    case regular

    var padding: EdgeInsets {
        switch self {
        case .compact: return .init(
            top: Constraint.smallPadding,
            leading: Constraint.regularPadding,
            bottom: Constraint.smallPadding,
            trailing: Constraint.regularPadding
        )
        case .regular: return .init(
            top: Constraint.padding,
            leading: Constraint.padding,
            bottom: Constraint.padding,
            trailing: Constraint.padding
        )
        }
    }
}
