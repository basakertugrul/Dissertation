import SwiftUI

// MARK: - View Extension for Layered Background
extension View {
    func addLayeredBackground(
        with color: Color,
        expandFullWidth: Bool = true,
        spacing: ContentSpacing = .regular,
        layerWeight: LayerWeight = .heavy
    ) -> some View {
        let cornerRadius: CGFloat = switch spacing {
        case .compact: Constraint.smallPadding
        case .regular: Constraint.padding
        }
        return self
            .padding(spacing.padding)
            .frame(maxWidth: expandFullWidth ? .infinity : .none)
            .background(
                color
                    .opacity(layerWeight.getValue())
                    .ignoresSafeArea()
            )
            .cornerRadius(cornerRadius)
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
