import SwiftUI

// MARK: - Daily Allowance Edit Sheet
extension View {
    @ViewBuilder
    func showDailyAllowanceSheet(
        isPresented: Binding<Bool>,
        currentAmount: Double,
        onSave: @escaping (Double) -> Void
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                /// Dimmed background
                Color.customRichBlack
                    .opacity(Constraint.Opacity.medium)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented.wrappedValue = false
                        }
                    }

                /// Edit Sheet
                DailyAllowanceEditView(
                    isPresented: isPresented,
                    currentAmount: currentAmount,
                    onSave: onSave
                )
                .scaleEffect(isPresented.wrappedValue ? 1.0 : 0.7)
                .opacity(isPresented.wrappedValue ? 1.0 : 0.0)
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
}

// MARK: - Daily Allowance Edit View
struct DailyAllowanceEditView: View {
    @Binding var isPresented: Bool
    let currentAmount: Double
    let onSave: (Double) -> Void

    @State private var amountText: String

    init(isPresented: Binding<Bool>, currentAmount: Double, onSave: @escaping (Double) -> Void) {
        self._isPresented = isPresented
        self.currentAmount = currentAmount
        self.onSave = onSave
        self._amountText = State(initialValue: String(format: "%.0f", currentAmount))
    }
    
    private var isValidAmount: Bool {
        guard let amount = Int(amountText), amount > 0, amount <= 9999 else { return false }
        return true
    }
    
    private var parsedAmount: Double {
        Double(amountText) ?? .zero
    }

    var body: some View {
        VStack(spacing: .zero) {
            /// Alert header
            VStack(spacing: Constraint.padding) {
                CustomTextView(
                    "Set Daily Limit",
                    font: .bodySmallBold,
                    color: .white
                )
                
                CustomTextView(
                    "Control daily spending with smart limits",
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

                    TextField("0", text: $amountText)
                        .font(TextFonts.titleSmall.font)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                }
                .padding(Constraint.regularPadding)
                .background(.customWhiteSand.opacity(Constraint.Opacity.low))
                .cornerRadius(Constraint.regularCornerRadius)
                .padding(Constraint.padding)
            }
            .frame(width: Constraint.largeImageSize)
            .padding(.vertical, Constraint.largePadding)
            .background(.customOliveGreen)

            /// Save Button
            Button(action: {
                if isValidAmount {
                    print(parsedAmount)
                    onSave(parsedAmount)
                    isPresented = false
                }
            }) {
                CustomTextView(
                    "Save",
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
