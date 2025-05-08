import SwiftUI

// MARK: - View Extension for Background
extension View {
    func customBackground(with color: Color) -> some View {
        ZStack {
            // Main background
            // Burgundy background
            color
                .edgesIgnoringSafeArea(.all)
            // Decorative circles
            Circle()
                .stroke(Color.whiteSand.opacity(0.1), lineWidth: 1)
                .frame(width: 240, height: 240)
                .position(
                    x: UIScreen.main.bounds.width * CGFloat(Int.random(in: 0...30)) / 100,
                    y: UIScreen.main.bounds.height * CGFloat(Int.random(in: 0...40)) / 100,
                )
            Circle()
                .stroke(Color.whiteSand.opacity(0.1), lineWidth: 1)
                .frame(width: 320, height: 320)
                .position(
                    x: UIScreen.main.bounds.width * CGFloat(Int.random(in: 40...80)) / 100,
                    y: UIScreen.main.bounds.height * CGFloat(Int.random(in: 20...50)) / 100,
                )

            self
        }
        .edgesIgnoringSafeArea(.all)
    }
}
