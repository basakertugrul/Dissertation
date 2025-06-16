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
                BalanceEntranceView(
                    initialBalance: currentAmount,
                    onSave: onSave,
                    onTouchedBackground: {
                    withAnimation {
                        isPresented.wrappedValue = false
                    }
                })
                .scaleEffect(isPresented.wrappedValue ? 1.0 : 0.7)
                .opacity(isPresented.wrappedValue ? 1.0 : 0.0)
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
}
