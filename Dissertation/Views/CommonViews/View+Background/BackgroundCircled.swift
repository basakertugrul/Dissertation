import SwiftUI

// MARK: - View Extension for Circled Background
extension View {
    private func getPosition() -> CGPoint {
        CGPoint(
            x: UIScreen.main.bounds.width * CGFloat(Int.random(in: 0...100)) * 0.01,
            y: UIScreen.main.bounds.height * CGFloat(Int.random(in: 0...50)) * 0.01
        )
    }

    func addCircledBackground(with color: Color) -> some View {
        let firstPosition: CGPoint = getPosition()
        let secondPosition: CGPoint = getPosition()

        return ZStack {
            /// Background color with opacity animation
            color
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: Constraint.animationDuration), value: firstPosition)

            /// First circle with animated position
            Circle()
                .stroke(.customWhiteSand.opacity(Constraint.Opacity.high), lineWidth: Constraint.mediumLineLenght)
                .frame(width: Constraint.regularImageSize, height: Constraint.regularImageSize)
                .position(firstPosition)
                .blur(radius: Constraint.blurRadius)
                .animation(.smooth(duration: Constraint.animationDuration), value: firstPosition)

            /// Second circle with animated position
            Circle()
                .stroke(.customWhiteSand.opacity(Constraint.Opacity.high), lineWidth: Constraint.mediumLineLenght)
                .frame(width: Constraint.largeImageSize, height: Constraint.largeImageSize)
                .position(secondPosition)
                .blur(radius: Constraint.blurRadius)
                .animation(.smooth(duration: Constraint.animationDuration), value: firstPosition)

            self
        }
    }
}
