import SwiftUI

// MARK: - View Extension for Animated Background
extension View {
    func addAnimatedBackground() -> some View {
        AnimatedBackgroundWrapper {
            self
        }
    }
}

struct AnimatedBackgroundWrapper<Content: View>: View {
    let content: Content
    @State private var animateGradient = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.customOliveGreen, .customBurgundy, .customGold],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.smooth(duration: 8).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            content
        }
    }
}
