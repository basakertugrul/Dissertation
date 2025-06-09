import SwiftUI
import Charts

struct BudgetZonesView: View {
    @Binding var expenses: [ExpenseViewModel]
    @Binding var totalBalance: Double
    @Binding var timeFrame: TimeFrame
    @Binding var dailyBalance: Double

    @State var lineChartItems: [LineChartItem] = []

    @Binding var backgroundColor: Color

    var body: some View {
        VStack(spacing: Constraint.padding) {
            timeFrameSelection(withColor: backgroundColor)

            LineChartView(
                data: $lineChartItems,
                goalMoneySpent: $dailyBalance
            )

        }
        .onAppear {
            assignLineChartItems()
        }
    }

    private func assignLineChartItems() {
        let groupedExpenses: [Date: [ExpenseViewModel]] = Dictionary(
            grouping: expenses,
            by: { Calendar.current.startOfDay(for: $0.date) }
        )
        let minDate = groupedExpenses.keys.min() ?? .now
        let newLineChartItems: [LineChartItem] = generateDateRange(from: minDate).map { date in
            let totalSpent = groupedExpenses[date]?.reduce(0) { $0 + $1.amount } ?? .zero
            return LineChartItem.createWithPound(date: date, moneySpent: totalSpent)
        }
        DispatchQueue.main.async {
            lineChartItems = newLineChartItems
        }
    }

    /// Time Frame Selection
    private func timeFrameSelection(withColor color: Color) -> some View {
        HStack(spacing: Constraint.smallPadding) {
            ForEach(TimeFrame.allCases, id: \.self) { frame in
                Button(action: {
                    withAnimation {
                        timeFrame = frame
                        DataController.shared.saveTimeFrame(frame)
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
                        spacing: .compact
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    /// Helper methods for the line chart
    private func generateDateRange(from startDate: Date) -> [Date] {
        let calendar = Calendar.current
        let endDate = removeTimeStamp(fromDate: calendar.startOfDay(for: .now))
        let startDate = removeTimeStamp(fromDate: startDate)

        if startDate > endDate { return [] }
        if startDate == endDate { return [startDate] }
        let dayCount = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0

        let returnArray: [Date] = (0...dayCount).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startDate)
        }
        return returnArray.map { removeTimeStamp(fromDate: $0) }
    }

    func removeTimeStamp(fromDate date: Date) -> Date {
        guard let newDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date)) else {
            fatalError("Failed to strip time from Date object")
        }
        return newDate
    }
}
