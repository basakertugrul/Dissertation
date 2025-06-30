import SwiftUI
import Charts

struct BudgetLineChartView: View {
    @Binding var data: [LineChartItem]
    @Binding var totalBudgetAccumulated: Double
    @State private var animatedLimitValue: Double = 0
    @State private var animatedSpentValue: Double = 0
    @State private var showChart: Bool = false
    @State private var colorGradientProgress: Double = 0.0
    @State private var isOverLimit: Bool = false

    var body: some View {
        VStack(spacing: Constraint.smallPadding) {
            CustomTextView("Budget", font: .bodyLargeBold, color: .customRichBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Constraint.padding)

            Chart {
                /// Daily Limit Bar
                BarMark(
                    x: .value("Type", "Limit"),
                    y: .value("Amount", animatedLimitValue)
                )
                .foregroundStyle(.customOliveGreen)
                .opacity(showChart ? 1.0 : 0.0)

                /// Spent Money Bar with Dynamic Gradient/Color
                BarMark(
                    x: .value("Type", "Expenses"),
                    y: .value("Amount", animatedSpentValue)
                )
                .foregroundStyle(isOverLimit ? .customBurgundy : .customOliveGreen)
                .opacity(showChart ? 1.0 : 0.0)

                /// Daily Limit Mark
                RuleMark(y: .value("Limit", animatedLimitValue))
                    .foregroundStyle(.customRichBlack.opacity(Constraint.Opacity.low))
                    .lineStyle(StrokeStyle(lineWidth: Constraint.tinyLineLenght, dash: [5]))
                    .annotation(alignment: .leading) {
                        CustomTextView.currency(
                            animatedLimitValue,
                            font: .bodySmallBold,
                            color: .customRichBlack.opacity(Constraint.Opacity.medium)
                        )
                        .frame(width: 100)
                    }

                /// Expenses Mark
                RuleMark(y: .value("Expenses", animatedSpentValue))
                    .foregroundStyle(.customRichBlack.opacity(Constraint.Opacity.low))
                    .annotation(alignment: .trailing) {
                        CustomTextView.currency(
                            animatedSpentValue,
                            font: .bodySmallBold,
                            color: .customRichBlack
                        )
                        .frame(width: 100)
                    }
            }
            .padding(.horizontal, Constraint.padding)
            .chartYAxis(.hidden)
            .preferredColorScheme(.light)
        }
        .frame(maxHeight: Constraint.regularImageSize)
        .padding(Constraint.regularPadding * 2)
        .background(
            RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                .fill(.white.shadow(.drop(radius: Constraint.shadowRadius)))
                .scaleEffect(showChart ? 1.0 : 0.95)
                .opacity(showChart ? 1.0 : 0.0)
        )
        .onAppear {
            HapticManager.shared.trigger(.light)
            animateChart()
        }
        .onChange(of: data) {
            HapticManager.shared.trigger(.medium)
            animateChart()
        }
        .onChange(of: totalBudgetAccumulated) { oldValue, newValue in
            if oldValue != newValue {
                HapticManager.shared.trigger(.selection)
                animateChart()
            }
        }
        .onTapGesture {
            HapticManager.shared.trigger(.light)
        }
        .onLongPressGesture {
            HapticManager.shared.trigger(.medium)
        }
    }

    private func animateChart() {
        /// Reset animations
        showChart = false
        animatedLimitValue = 0
        animatedSpentValue = 0
        colorGradientProgress = 0.0

        let spentMoney = data.count > 1 ? data[1].moneySpent : 0

        /// Progressive animation sequence
        withAnimation(.smooth(duration: 0.2)) {
            showChart = true
        }

        /// Animate limit bar first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.smooth()) {
                animatedLimitValue = totalBudgetAccumulated
            }
        }

        /// Animate spent bar after limit bar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.smooth()) {
                animatedSpentValue = spentMoney
            }

            animateColorTransition()
        }
    }

    private func animateColorTransition() {
        DispatchQueue.main.async() {
            withAnimation(.smooth(duration: 0.3)) {
                isOverLimit = animatedLimitValue < animatedSpentValue
            }
        }
    }
}
