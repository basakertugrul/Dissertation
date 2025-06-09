import SwiftUI
import Charts

struct BudgetZonesView: View {
    @Binding var expenses: [ExpenseViewModel]
    @Binding var totalBalance: Double
    @Binding var timeFrame: TimeFrame
    @Binding var dailyBalance: Double
    @Binding var backgroundColor: Color

    @State private var lineChartItems: [LineChartItem] = []

    var body: some View {
        VStack(spacing: Constraint.regularPadding) {
            timeFrameSelection(withColor: backgroundColor)

            BudgetLineChartView(data: $lineChartItems)
        }
        .onAppear {
            assignLineChartItems()
        }
        .onChange(of: expenses) { _, _ in
            assignLineChartItems()
        }
        .onChange(of: timeFrame) { _, _ in
            assignLineChartItems()
        }
        .onChange(of: dailyBalance) { _, _ in
            assignLineChartItems()
        }
    }

    private func assignLineChartItems() {
        let calendar = Calendar.current
        let now = Date()
        let totalSpent: Double

        /// Calculate timeframe limit
        let timeFrameLimit: Double
        
        let startDay = expenses.sorted(by: { left, right in left.date < right.date }).first?.date ?? .now
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
            timeFrameLimit = dailyBalance * daysCount
        case .monthly:
            var daysCount: Double
            let staticNumber: Int = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
            if startDay < calendar.date(byAdding: .day, value: -staticNumber, to: now) ?? now {
                daysCount = Double(staticNumber)
            } else {
                daysCount = daysBetween(startDay, now)
            }
            timeFrameLimit = dailyBalance * daysCount
        case .yearly:
            var daysCount: Double
            let staticNumber: Int = calendar.range(of: .day, in: .year, for: now)?.count ?? 165
            if startDay < calendar.date(byAdding: .day, value: -staticNumber, to: now) ?? now {
                daysCount = Double(staticNumber)
            } else {
                daysCount = daysBetween(startDay, now)
            }
            timeFrameLimit = dailyBalance * daysCount
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

        lineChartItems = [
            LineChartItem.createWithPound(date: now, moneySpent: timeFrameLimit), /// Limit bar
            LineChartItem.createWithPound(date: now, moneySpent: totalSpent) /// Spent bar
        ]
    }

    private func timeFrameSelection(withColor color: Color) -> some View {
         HStack(spacing: Constraint.smallPadding) {
             ForEach(TimeFrame.allCases, id: \.self) { frame in
                 Button(action: {
                     withAnimation {
                         if timeFrame != frame {
                             timeFrame = frame
                             DataController.shared.saveTimeFrame(frame)
                         }
                     }
                 }) {
                     CustomTextView(
                         frame.rawValue,
                         font: timeFrame == frame ? .labelLargeBold : .labelLarge,
                         color: timeFrame == frame ? .customWhiteSand : .customWhiteSand.opacity(Constraint.Opacity.medium),
                         uppercase: true
                     )
                     .fixedSize(horizontal: true, vertical: false)
                     .addLayeredBackground(
                         with: timeFrame == frame
                         ? color
                         : .customRichBlack,
                         expandFullWidth: false,
                         spacing: .compact,
                         keepTheColor: timeFrame == frame
                     )
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
