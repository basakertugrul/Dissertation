import SwiftUI

// MARK: - Loading Overlay Component
struct LoadingOverlayView: View {
    @Binding var isPresented: Bool

    /// Internal state for animations
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.3
    
    var body: some View {
        if isPresented {
            ZStack {
                /// Background overlay
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(Constraint.Opacity.medium))
                    .ignoresSafeArea()
                
                /// Loading content
                VStack(spacing: Constraint.padding) {
                    ZStack {
                        /// Background circle
                        appIconImage
                            .frame(width: 70, height: 70)

                        Circle()
                            .stroke(Color.customWhiteSand.opacity(0.2), lineWidth: 3)
                            .frame(width: 80, height: 80)
                        
                        /// Animated arc
                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        .customWhiteSand,
                                        .customWhiteSand.opacity(0.8),
                                        .customWhiteSand.opacity(0.3),
                                        .clear
                                    ]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(rotationAngle))
                        
                        /// Pulse effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        .customWhiteSand.opacity(pulseOpacity),
                                        .clear
                                    ]),
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseScale)
                    }
                    
                    /// Loading text
                    CustomTextView(NSLocalizedString("loading", comment: ""), font: .bodyLargeBold, color: .customRichBlack)
                }
                .padding(Constraint.largePadding)
                .background(
                    RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                        .fill(
                            Color.customWhiteSand
                                .opacity(Constraint.Opacity.high)
                        )
                        .shadow(color: .customRichBlack.opacity(Constraint.Opacity.medium), radius: Constraint.shadowRadius)
                )
            }
            .transition(.scale(scale: 0.8).combined(with: .opacity))
            .onAppear {
                startAnimations()
            }
            .onDisappear {
                stopAnimations()
            }
            .zIndex(10)
        }
    }

    // MARK: - Animation Control
    private func startAnimations() {
        HapticManager.shared.trigger(.buttonTap)
        
        /// Continuous rotation animation - faster and smoother
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        /// Pulse animation - slower and more subtle
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
            pulseOpacity = 0.1
        }
    }
    
    private func stopAnimations() {
        /// Reset animation states
        withAnimation(.none) {
            rotationAngle = 0
            pulseScale = 1.0
            pulseOpacity = 0.3
        }
    }
}

// MARK: - View Extension
extension View {
    func loadingOverlay(_ isPresented: Binding<Bool>) -> some View {
        self.overlay(
            LoadingOverlayView(isPresented: isPresented)
        )
    }
}
