import SwiftUI

// MARK: - Layered Background Extension
extension View {
    func addLayeredBackground(
        _ color: Color,
        style: BackgroundStyle = .card(isColorFilled: false)
    ) -> some View {
        self
            .padding(style.padding)
            .frame(maxWidth: style.expandsWidth ? .infinity : nil)
            .background(
                style.backgroundView(with: color, cornerRadius: style.cornerRadius)
                    .shadow(
                        color: Color.black.opacity(Constraint.Opacity.low),
                        radius: 8,
                        y: 4
                    )
            )
    }
}

// MARK: - Background Style
enum BackgroundStyle {
    case card(isColorFilled: Bool = false),
         banner,
         compact(isColorFilled: Bool = false),
         standard
    
    var padding: EdgeInsets {
        switch self {
        case .card:
            EdgeInsets(
                top: Constraint.padding,
                leading: Constraint.padding,
                bottom: Constraint.padding,
                trailing: Constraint.padding
            )
        case .banner:
            EdgeInsets(
                top: Constraint.largePadding,
                leading: Constraint.largePadding,
                bottom: Constraint.largePadding,
                trailing: Constraint.largePadding
            )
        case .compact:
            EdgeInsets(
                top: Constraint.smallPadding,
                leading: Constraint.regularPadding,
                bottom: Constraint.smallPadding,
                trailing: Constraint.regularPadding
            )
        case .standard:
            EdgeInsets(
                top: Constraint.regularPadding,
                leading: Constraint.padding,
                bottom: Constraint.regularPadding,
                trailing: Constraint.padding
            )
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .card, .banner, .compact, .standard:
            Constraint.cornerRadius
        }
    }

    var expandsWidth: Bool {
        if case .compact = self {
            return false
        }
        return true
    }

    @ViewBuilder
    func backgroundView(with color: Color, cornerRadius: CGFloat) -> some View {
        switch self {
        case .card(isColorFilled: false), .compact(isColorFilled: false):
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color.gradient())
                .stroke(
                    borderColor(for: color),
                    lineWidth: 1.5
                )
        case .compact(isColorFilled: true), .card(isColorFilled: true), .banner:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .stroke(
                    borderColor(for: color),
                    lineWidth: 1.5
                )
        case .standard:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial.opacity(Constraint.Opacity.medium))
                .stroke(
                    borderColor(for: color),
                    lineWidth: 1.5
                )
        }
    }

    func borderColor(for color: Color) -> Color {
        switch self {
        case .banner, .compact:
            Color.clear
        default:
            .customWhiteSand.opacity(Constraint.Opacity.low)
        }
    }
}

// MARK: - Color Extension
private extension Color {
    func gradient() -> LinearGradient {
        let topOpacity = Constraint.Opacity.high
        let bottomOpacity = Constraint.Opacity.medium
    
        return LinearGradient(
            colors: [self.opacity(topOpacity), self.opacity(bottomOpacity)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview
struct LayeredBackgroundDisplayItems: View {
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Card Style Full Example")
                .addLayeredBackground(.blue, style: .card(isColorFilled: true))

            Text("Card Style Non Full Example")
                .addLayeredBackground(.blue, style: .card(isColorFilled: false))

            Text("Banner Style Example")
                .foregroundColor(.white)
                .addLayeredBackground(.purple, style: .banner)
            
            Text("Compact Full Style Example")
                .addLayeredBackground(.teal, style: .compact(isColorFilled: true))
            
            Text("Compact Not Full Style Example")
                .addLayeredBackground(.teal, style: .compact(isColorFilled: false))
            
            Text("Standard Style Example")
                .addLayeredBackground(.teal, style: .standard)
        }
        .padding()
        .background(.secondary)
    }
}

#Preview {
    LayeredBackgroundDisplayItems()
}
