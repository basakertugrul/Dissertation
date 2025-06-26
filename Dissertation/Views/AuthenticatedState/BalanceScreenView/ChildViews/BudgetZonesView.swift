import SwiftUI
import Charts

// MARK: - Animated Budget Zones View
struct BudgetZonesView: View {
    @Binding var expenses: [ExpenseViewModel]
    @Binding var totalBalance: Double
    @Binding var timeFrame: TimeFrame
    @Binding var dailyBalance: Double
    @Binding var startDay: Date
    
    var backgroundColor: Color {
        totalBalance < 0 ? .customOliveGreen : .customBurgundy
    }

    @State private var lineChartItems: [LineChartItem] = []
    @State var timeFrameBalanceLimit: Double = .zero
    @State private var showContent: Bool = false
    @State private var animatedScale: CGFloat = 0.95
    @State private var animatedOpacity: Double = 0.0

    var body: some View {
        VStack(spacing: Constraint.regularPadding) {
            timeFrameSelection(withColor: backgroundColor)
                .scaleEffect(animatedScale)
                .opacity(animatedOpacity)

            BudgetLineChartView(data: $lineChartItems, totalBudgetAccumulated: $timeFrameBalanceLimit)
                .scaleEffect(animatedScale)
                .opacity(animatedOpacity)
        }
        .onAppear {
            HapticManager.shared.trigger(.light)
            assignLineChartItems()
            animateAppearance()
        }
        .onChange(of: expenses) { _, _ in
            HapticManager.shared.trigger(.light)
            assignLineChartItems()
            animateContentChange()
        }
        .onChange(of: timeFrame) { _, _ in
            HapticManager.shared.trigger(.selection)
            assignLineChartItems()
            animateContentChange()
        }
        .onChange(of: dailyBalance) { oldValue, newValue in
            if oldValue != newValue {
                HapticManager.shared.trigger(.medium)
                assignLineChartItems()
                animateContentChange()
            }
        }
    }
    
    private func animateAppearance() {
        withAnimation(.smooth(duration: 0.3).delay(0.1)) {
            showContent = true
            animatedScale = 1.0
            animatedOpacity = 1.0
        }
    }
    
    private func animateContentChange() {
        // Quick scale down animation
        withAnimation(.smooth(duration: 0.15)) {
            animatedScale = 0.98
            animatedOpacity = 0.8
        }
        
        // Scale back up with spring animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.smooth()) {
                animatedScale = 1.0
                animatedOpacity = 1.0
            }
        }
    }

    private func assignLineChartItems() {
        let calendar = Calendar.current
        let now = Date()
        let totalSpent: Double

        /// Calculate timeframe limit
        let timeFrameLimit: Double
        
        let startDay = startDay
        switch timeFrame {
        case .daily:
            timeFrameLimit = dailyBalance
        case .weekly:
            var daysCount: Double
            let staticNumber: Int = 7
            if startDay < calendar.date(byAdding: .day, value: -staticNumber, to: now) ?? now {
                daysCount = Double(staticNumber)
            } else {
                daysCount = daysBetween(startDay, now)
            }
            let totalTimeFrameLimit = dailyBalance * daysCount
            timeFrameLimit = totalTimeFrameLimit == 0 ? dailyBalance : totalTimeFrameLimit
        case .monthly:
            var daysCount: Double
            let staticNumber: Int = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
            if startDay < calendar.date(byAdding: .day, value: -staticNumber, to: now) ?? now {
                daysCount = Double(staticNumber)
            } else {
                daysCount = daysBetween(startDay, now)
            }
            let totalTimeFrameLimit = dailyBalance * daysCount
            timeFrameLimit = totalTimeFrameLimit == 0 ? dailyBalance : totalTimeFrameLimit
        case .yearly:
            var daysCount: Double
            let staticNumber: Int = calendar.range(of: .day, in: .year, for: now)?.count ?? 165
            if startDay < calendar.date(byAdding: .day, value: -staticNumber, to: now) ?? now {
                daysCount = Double(staticNumber)
            } else {
                daysCount = daysBetween(startDay, now)
            }
            let totalTimeFrameLimit = dailyBalance * daysCount
            timeFrameLimit = totalTimeFrameLimit == 0 ? dailyBalance : totalTimeFrameLimit
        }

        switch timeFrame {
        case .daily:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
            totalSpent = expenses.filter { $0.date >= startOfDay && $0.date < endOfDay }
                .reduce(0) { $0 + $1.amount }

        case .weekly:
            let startOf7Days = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) ?? now
            let endOf7Days = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) ?? now
            totalSpent = expenses.filter { $0.date >= startOf7Days && $0.date < endOf7Days }
                .reduce(0) { $0 + $1.amount }

        case .monthly:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? now
            totalSpent = expenses.filter { $0.date >= startOfMonth && $0.date < endOfMonth }
                .reduce(0) { $0 + $1.amount }

        case .yearly:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? now
            totalSpent = expenses.filter { $0.date >= startOfYear && $0.date < endOfYear }
                .reduce(0) { $0 + $1.amount }
        }

        timeFrameBalanceLimit = timeFrameLimit
        lineChartItems = [
            LineChartItem.createWithPound(date: now, moneySpent: timeFrameLimit), /// Limit bar
            LineChartItem.createWithPound(date: now, moneySpent: totalSpent) /// Spent bar
        ]
    }

    private func timeFrameSelection(withColor color: Color) -> some View {
         HStack(spacing: Constraint.smallPadding) {
             ForEach(TimeFrame.allCases, id: \.self) { frame in
                 Button(action: {
                     HapticManager.shared.trigger(.buttonTap)
                     withAnimation(.smooth()) {
                         if timeFrame != frame {
                             timeFrame = frame
                             let _ = DataController.shared.saveTimeFrame(frame)
                         }
                     }
                 }) {
                     CustomTextView(
                         frame.rawValue,
                         font: timeFrame == frame ? .labelLargeBold : .labelLarge,
                         color: timeFrame == frame ? .customWhiteSand : .customWhiteSand.opacity(Constraint.Opacity.high),
                         uppercase: true
                     )
                     .fixedSize(horizontal: true, vertical: false)
                     .addLayeredBackground(
                        timeFrame == frame
                        ? backgroundColor == .customBurgundy ? .customOliveGreen : .customBurgundy
                        : .customRichBlack.opacity(Constraint.Opacity.high),
                        style: .compact(isColorFilled: timeFrame == frame ? true : false)
                     )
                     .scaleEffect(timeFrame == frame ? 1.05 : 1.0)
                 }
                 .buttonStyle(PlainButtonStyle())
                 .onLongPressGesture {
                     HapticManager.shared.trigger(.longPress)
                 }
             }
         }
         .frame(maxWidth: .infinity, alignment: .center)
     }

    func daysBetween(_ date1: Date, _ date2: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return Double(abs(components.day ?? 0))
    }
}
