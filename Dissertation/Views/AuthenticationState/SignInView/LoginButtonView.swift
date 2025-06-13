import SwiftUI

// MARK: - Sign In Button Component
struct LoginButtonView: View {
    let title: String
    let icon: String
    var isApple = false
    var isGlass = false
    var isSelected = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constraint.smallPadding) {
                Image(systemName: icon)
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(textColor)
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                CustomTextView(title, font: .labelLargeBold, color: textColor)
            }
            .padding(.vertical, Constraint.regularPadding)
            .addLayeredBackground(with: backgroundFill, spacing: .compact)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(
                color: isSelected ? .white.opacity(Constraint.Opacity.low) : .black.opacity(Constraint.Opacity.tiny),
                radius: isSelected ? Constraint.largeShadowRadius : Constraint.shadowRadius,
                x: 0,
                y: isSelected ? Constraint.regularPadding : Constraint.tinyPadding
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if isApple { return .white }
        return .primary
    }
    
    private var backgroundFill: Color {
        if isApple {
            return .black
        } else if isGlass {
            return .customGold
        }
        return .clear
    }
}
