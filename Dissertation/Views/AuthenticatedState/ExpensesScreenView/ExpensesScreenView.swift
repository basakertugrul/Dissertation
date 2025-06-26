import SwiftUI

// MARK: - Expenses Screen
struct ExpensesScreenView: View {
    @Binding var expenses: [ExpenseViewModel]
    let onExpenseEdit: (ExpenseViewModel) -> Void
    
    @State private var showContent: Bool = false
    @State private var sectionOpacity: Double = 0.0
    @State private var sectionOffset: CGFloat = 30

    private var groupedExpenses: [String: [ExpenseViewModel]] {
        Dictionary(grouping: expenses) { expense in
            /// Group by date
            if expense.isToday() {
                return "TODAY"
            } else if expense.isYesterday() {
                return "YESTERDAY"
            } else if expense.isInLastWeek() {
                return "THIS WEEK"
            } else if expense.isInLastMonth() {
                return "THIS MONTH"
            } else {
                return "EARLIER"
            }
        }
    }

    private var sortedKeys: [String] {
        let order = ["TODAY", "YESTERDAY", "THIS WEEK", "THIS MONTH", "EARLIER"]
        return groupedExpenses.keys.sorted { (key1, key2) in
            let index1 = order.firstIndex(of: key1) ?? Int.max
            let index2 = order.firstIndex(of: key2) ?? Int.max
            return index1 < index2
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constraint.smallPadding) {
                ForEach(Array(sortedKeys.enumerated()), id: \.element) { index, key in
                    if let expensesForDate = groupedExpenses[key] {
                        VStack(alignment: .leading, spacing: Constraint.smallPadding) {
                            CustomTextView(
                                key,
                                font: .labelLarge,
                                color: Color.customRichBlack.opacity(Constraint.Opacity.medium)
                            )
                            .opacity(sectionOpacity)
                            .offset(x: sectionOffset)

                            ForEach(Array(expensesForDate.enumerated()), id: \.element.id) { expenseIndex, expense in
                                ExpenseItemView(expense: expense) {
                                    HapticManager.shared.trigger(.edit)
                                    onExpenseEdit(expense)
                                }
                                .opacity(sectionOpacity)
                                .offset(x: sectionOffset)
                            }
                        }
                        .padding(.vertical, Constraint.tinyPadding)
                        .onAppear {
                            animateSectionAppearance(delay: Double(index) * 0.1)
                        }
                    }
                }
            }
            .padding(Constraint.padding)
        }
        .onAppear {
            animateContentAppearance()
        }
        .onChange(of: expenses) { _, _ in
            animateContentUpdate()
        }
        .refreshable {
            HapticManager.shared.trigger(.navigation)
        }
    }
    
    private func animateContentAppearance() {
        withAnimation(.smooth(duration: 0.4)) {
            showContent = true
        }
        
        // Staggered section animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.smooth(duration: 0.6)) {
                sectionOpacity = 1.0
                sectionOffset = 0
            }
        }
    }
    
    private func animateSectionAppearance(delay: Double) {
        // Individual section animation with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.smooth()) {
                // This will be handled by the main animation
            }
        }
    }
    
    private func animateContentUpdate() {
        // Subtle update animation when expenses change
        HapticManager.shared.trigger(.selection)
        withAnimation(.smooth(duration: 0.3)) {
            sectionOpacity = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.smooth(duration: 0.4)) {
                sectionOpacity = 1.0
            }
        }
    }
}

// MARK: - Helper Views
struct ExpenseItemView: View {
    let expense: ExpenseViewModel
    let onTap: () -> Void
    
    @State private var itemScale: CGFloat = 0.95
    @State private var itemOpacity: Double = 0.0
    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: {
            HapticManager.shared.trigger(.buttonTap)
            animateButtonPress()
            onTap()
        }) {
            HStack {
                /// Name and date
                VStack(alignment: .leading, spacing: Constraint.tinyPadding) {
                    CustomTextView(expense.name, font: .bodySmall, color: .customWhiteSand)
                        .frame(height: 20)
                    CustomTextView(expense.getDateString(), font: .labelMedium, color: .customWhiteSand.opacity(Constraint.Opacity.high))
                }
                Spacer()
                /// Amount
                CustomTextView.currency(expense.amount, font: .bodySmallBold, color: .white)
            }
            .addLayeredBackground(.customGold, style: .card())
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .scaleEffect(itemScale)
        .opacity(itemOpacity)
        .onAppear {
            animateItemAppearance()
        }
        .onLongPressGesture {
            HapticManager.shared.trigger(.longPress)
            // Could add additional long press functionality here
        }
    }
    
    private func animateItemAppearance() {
        withAnimation(.smooth().delay(0.1)) {
            itemScale = 1.0
            itemOpacity = 1.0
        }
    }
    
    private func animateButtonPress() {
        withAnimation(.smooth(duration: 0.1)) {
            isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.smooth()) {
                isPressed = false
            }
        }
    }
}
