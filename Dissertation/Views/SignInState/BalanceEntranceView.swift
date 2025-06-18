import SwiftUI

// MARK: - Balance Entrance View
struct BalanceEntranceView: View {
    @State private var balanceText: String
    @State private var selectedPreset: Double? = nil
    let onSave: (Double) -> Void
    let onTouchedBackground: () -> Void
    let hasSetBefore: Bool

    // Preset amounts
    private let presetAmounts: [Double] = [10, 20, 40, 50]
    
    // MARK: - Initializer with optional initial balance
    init(initialBalance: Double? = nil, onSave: @escaping (Double) -> Void, onTouchedBackground: @escaping () -> Void) {
        self.onSave = onSave
        self.onTouchedBackground = onTouchedBackground
        self.hasSetBefore = initialBalance != nil
    
        if let initialBalance = initialBalance, initialBalance > 0 {
            self._balanceText = State(initialValue: String(format: "%.0f", initialBalance))
            // Check if initial balance matches any preset
            if presetAmounts.contains(initialBalance) {
                self._selectedPreset = State(initialValue: initialBalance)
            }
        } else {
            self._balanceText = State(initialValue: "")
        }
    }
    
    private var isValidAmount: Bool {
        guard let amount = Int(balanceText), amount > 0, amount <= 9999 else { return false }
        return true
    }
    
    private var parsedAmount: Double {
        Double(balanceText) ?? .zero
    }

    var body: some View {
        ZStack {
            /// Dimmed background
            Color.black.ignoresSafeArea()
            Rectangle()
                .fill(.ultraThinMaterial.opacity(Constraint.Opacity.medium))
                .ignoresSafeArea()
                .onTapGesture { onTouchedBackground() }

            VStack(spacing: .zero) {
                /// Header Section
                VStack(spacing: Constraint.padding) {
                    CustomTextView(
                        "Set Daily Budget",
                        font: .bodySmallBold,
                        color: .white
                    )
                    
                    CustomTextView(
                        hasSetBefore ? "How much do you want to spend per day?" : "Control daily spending with smart limits",
                        font: .labelLarge,
                        color: .customWhiteSand
                    )
                    .multilineTextAlignment(.center)
                    
                    /// Amount Input
                    ZStack {
                        CustomTextView(
                            "£",
                            font: .titleSmall,
                            color: .customWhiteSand
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("0", text: $balanceText)
                            .font(TextFonts.titleSmall.font)
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .onChange(of: balanceText) { oldValue, newValue in
                                // Only clear selection if user manually typed (not from preset)
                                if selectedPreset != nil && newValue != String(format: "%.0f", selectedPreset!) {
                                    selectedPreset = nil
                                }
                            }
                    }
                    .padding(Constraint.regularPadding)
                    .background(.customWhiteSand.opacity(Constraint.Opacity.low))
                    .cornerRadius(Constraint.regularCornerRadius)
                    .padding(Constraint.padding)
                    
                    /// Quick Select Presets
                    VStack(spacing: Constraint.smallPadding) {
                        CustomTextView(
                            "Quick Select",
                            font: .labelMedium,
                            color: .customWhiteSand
                        )
                        
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: Constraint.smallPadding), count: 2),
                            spacing: Constraint.smallPadding
                        ) {
                            ForEach(presetAmounts, id: \.self) { amount in
                                presetButton(for: amount)
                            }
                        }
                    }
                    .padding(.horizontal, Constraint.padding)
                }
                .frame(width: Constraint.largeImageSize)
                .padding(.vertical, Constraint.largePadding)
                .background(.customOliveGreen)
                
                /// Continue Button
                Button(action: {
                    if isValidAmount {
                        onSave(parsedAmount)
                    }
                }) {
                    CustomTextView(
                        "Continue",
                        font: .bodySmallBold,
                        color: isValidAmount ? .customOliveGreen : .customOliveGreen.opacity(Constraint.Opacity.medium)
                    )
                }
                .frame(width: Constraint.largeImageSize, height: Constraint.extremeIconSize)
                .background(.white)
                .disabled(!isValidAmount)
            }
            .frame(width: Constraint.largeImageSize)
            .background(
                Color.white
                    .shadow(radius: Constraint.shadowRadius)
            )
            .clipShape(RoundedRectangle(cornerRadius: Constraint.cornerRadius))
            .onTapGesture {
                hideKeyboard()
            }
            .onDisappear {
                hideKeyboard()
            }
        }
    }
    
    // MARK: - Preset Button
    @ViewBuilder
    private func presetButton(for amount: Double) -> some View {
        let isSelected = selectedPreset == amount
        
        Button(action: {
            withAnimation(.smooth(duration: 0.2)) {
                selectedPreset = amount
                balanceText = String(format: "%.0f", amount)
            }
        }) {
            CustomTextView(
                "£\(Int(amount))",
                font: .bodySmall,
                color: isSelected ? .customOliveGreen : .customWhiteSand
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constraint.smallPadding)
            .background(
                RoundedRectangle(cornerRadius: Constraint.smallCornerRadius)
                    .fill(isSelected ? .white : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constraint.smallCornerRadius)
                            .stroke(
                                isSelected ? .clear : .customWhiteSand.opacity(Constraint.Opacity.low),
                                lineWidth: 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
