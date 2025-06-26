import SwiftUI

// MARK: - Quick Actions View
struct QuickActionsView: View {
    let onExpenseAdded: (Double) -> Void
    let onCameraOpen: () -> Void

    private let quickAmounts: [Double] = [1, 2, 5, 10]

    @State private var buttonScales: [Double: CGFloat] = [:]
    @State private var cameraScale: CGFloat = 1.0
    @State private var cameraRotation: Double = 0
    
    var body: some View {
        VStack(spacing: Constraint.padding) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.customWhiteSand)
                    .font(.system(size: 18, weight: .semibold))
                
                CustomTextView(
                    "Quick Actions",
                    font: .titleMediumBold,
                    color: .customWhiteSand
                )
                
                Spacer()
                
                CustomTextView(
                    "Tap to add expense",
                    font: .labelSmall,
                    color: .customWhiteSand.opacity(0.8)
                )
            }
            .padding(.horizontal)
            
            HStack(spacing: Constraint.smallPadding) {
                ForEach(quickAmounts, id: \.self) { amount in
                    ExpenseButton(
                        amount: amount,
                        scale: buttonScales[amount] ?? 1.0,
                        onTap: {
                            animateExpenseButton(amount: amount)
                            HapticManager.shared.trigger(.success)
                            onExpenseAdded(amount)
                        }
                    )
                }
                
                CameraButton(
                    scale: cameraScale,
                    rotation: cameraRotation,
                    onTap: {
                        animateCameraButton()
                        HapticManager.shared.trigger(.medium)
                        onCameraOpen()
                    }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, Constraint.padding)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.customOliveGreen.opacity(0.8),
                    Color.customBurgundy.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Constraint.cornerRadius))
        .shadow(color: .customRichBlack.opacity(0.15), radius: 8, x: 0, y: 4)
        .onAppear {
            setupButtonScales()
        }
    }
    
    private func setupButtonScales() {
        for amount in quickAmounts {
            buttonScales[amount] = 1.0
        }
    }
    
    private func animateExpenseButton(amount: Double) {
        withAnimation(.easeInOut(duration: 0.1)) {
            buttonScales[amount] = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                buttonScales[amount] = 1.0
            }
        }
    }
    
    private func animateCameraButton() {
        withAnimation(.easeInOut(duration: 0.1)) {
            cameraScale = 0.95
            cameraRotation = 15
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cameraScale = 1.0
                cameraRotation = 0
            }
        }
    }
}

// MARK: - Expense Button
struct ExpenseButton: View {
    let amount: Double
    let scale: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Constraint.tinyPadding) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.customWhiteSand)
                
                CustomTextView.currency(
                    amount,
                    font: .labelSmallBold,
                    color: .customWhiteSand
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                    .fill(Color.customWhiteSand.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                            .stroke(Color.customWhiteSand.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(scale)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Camera Button
struct CameraButton: View {
    let scale: CGFloat
    let rotation: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Constraint.tinyPadding) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.customWhiteSand)
                    .rotationEffect(.degrees(rotation))
                
                CustomTextView(
                    "Scan",
                    font: .labelMedium,
                    color: .customWhiteSand
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                    .fill(Color.customWhiteSand.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                            .stroke(Color.customWhiteSand.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .scaleEffect(scale)
        .buttonStyle(PlainButtonStyle())
    }
}
