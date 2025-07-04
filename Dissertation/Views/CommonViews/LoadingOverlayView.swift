import SwiftUI

// MARK: - Loading Overlay Component
struct LoadingOverlayView: View {
    @Binding var isPresented: Bool

    /// Internal state for animations
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var contentScale: CGFloat = 0.8
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        if isPresented {
            ZStack {
                /// Background overlay
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(Constraint.Opacity.medium))
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                /// Loading content
                VStack(spacing: Constraint.padding) {
                    ZStack {
                        /// Background circle
                        Image(uiImage: Bundle.main.icon ?? UIImage())
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
                                        .customWhiteSand.opacity(0.3),
                                        .clear
                                    ]),
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseScale)
                            .opacity(2 - pulseScale)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Color.customWhiteSand
                        .opacity(Constraint.Opacity.low)
                )
                .scaleEffect(contentScale)
                .opacity(contentOpacity)
                .transition(.scale.combined(with: .opacity))
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
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
        /// Content entrance animation
        HapticManager.shared.trigger(.buttonTap)
        withAnimation(.smooth()) {
            contentScale = 1.0
            contentOpacity = 1.0
        }
        
        /// Continuous rotation animation
        withAnimation(.smooth(duration: 1.5).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        /// Pulse animation
        withAnimation(.smooth(duration: 1.5).repeatForever(autoreverses: false)) {
            pulseScale = 1.5
        }
    }
    
    private func stopAnimations() {
        /// Reset all animation states
        contentScale = 0.8
        contentOpacity = 0
        
        /// Stop repeating animations by setting to current values
        rotationAngle = rotationAngle.truncatingRemainder(dividingBy: 360)
        pulseScale = 1.0
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
