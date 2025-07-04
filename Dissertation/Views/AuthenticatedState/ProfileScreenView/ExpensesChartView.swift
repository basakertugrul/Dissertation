import SwiftUI
import Charts
import StoreKit

// MARK: - Chart Data Models
struct ExpenseChartData: Identifiable {
    let id = UUID()
    let period: String
    let amount: Double
    let date: Date
}

enum ChartTimeFrame: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    var displayName: String {
        switch self {
        case .daily: return NSLocalizedString("daily", comment: "")
        case .weekly: return NSLocalizedString("weekly", comment: "")
        case .monthly: return NSLocalizedString("monthly", comment: "")
        }
    }
    
    var subtitle: String {
        switch self {
        case .daily: return NSLocalizedString("this_week", comment: "")
        case .weekly: return NSLocalizedString("last_12_weeks", comment: "")
        case .monthly: return NSLocalizedString("last_12_months", comment: "")
        }
    }
}

// MARK: - Expense Chart View
struct ExpenseChartView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var selectedTimeFrame: ChartTimeFrame = .daily
    @State private var animatedData: [ExpenseChartData] = []
    @State private var showChart: Bool = false
    
    var chartData: [ExpenseChartData] {
        switch selectedTimeFrame {
        case .daily:
            return generateDailyData()
        case .weekly:
            return generateWeeklyData()
        case .monthly:
            return generateMonthlyData()
        }
    }
    
    var body: some View {
        VStack(spacing: Constraint.padding) {
            headerView
            chartSegmentedControl
            chartView
                .frame(maxHeight: Constraint.regularImageSize)
                .padding(Constraint.regularPadding)
                .background(
                    RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                        .fill(.white.shadow(.drop(radius: Constraint.shadowRadius)))
                )
                .opacity(showChart ? 1.0 : 0.0)
                .scaleEffect(showChart ? 1.0 : 0.95)
                .onTapGesture {
                    HapticManager.shared.trigger(.light)
                }
                .onLongPressGesture {
                    HapticManager.shared.trigger(.medium)
                }
        }
        .addLayeredBackground(.customBurgundy.opacity(Constraint.Opacity.low), style: .card(isColorFilled: true))
        .onAppear {
            HapticManager.shared.trigger(.light)
            animateChart()
        }
        .onChange(of: selectedTimeFrame) { _, _ in
            HapticManager.shared.trigger(.medium)
            animateChart()
        }
        .onChange(of: appState.expenseViewModels) { _, _ in
            HapticManager.shared.trigger(.selection)
            animateChart()
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundColor(.customBurgundy)
                .font(.body)
            
            VStack(alignment: .leading, spacing: Constraint.tinyPadding) {
                CustomTextView(
                    NSLocalizedString("expense_trends", comment: ""),
                    font: .bodyLargeBold,
                    color: .customRichBlack
                )
                
                CustomTextView(
                    selectedTimeFrame.subtitle,
                    font: .labelMedium,
                    color: .customRichBlack.opacity(Constraint.Opacity.medium)
                )
            }
            
            Spacer()
            
            Image(systemName: "chart.bar.xaxis")
                .foregroundColor(.customBurgundy)
                .font(.body)
        }
    }
    
    private var chartSegmentedControl: some View {
        HStack(spacing: Constraint.smallPadding) {
            ForEach(ChartTimeFrame.allCases, id: \.self) { timeFrame in
                Button {
                    HapticManager.shared.trigger(.selection)
                    withAnimation(.smooth) {
                        selectedTimeFrame = timeFrame
                    }
                } label: {
                    CustomTextView(
                        timeFrame.displayName,
                        font: .labelMedium,
                        color: selectedTimeFrame == timeFrame ? .white : .customRichBlack
                    )
                    .padding(.horizontal, Constraint.regularPadding)
                    .padding(.vertical, Constraint.smallPadding)
                    .background(
                        RoundedRectangle(cornerRadius: Constraint.smallCornerRadius)
                            .fill(selectedTimeFrame == timeFrame ? .customBurgundy : .white.opacity(Constraint.Opacity.medium))
                    )
                }
            }
        }
    }
    
    private var chartView: some View {
        Chart {
            ForEach(animatedData) { data in
                BarMark(
                    x: .value("Period", data.period),
                    y: .value("Amount", data.amount)
                )
                .foregroundStyle(
                    isCurrentPeriod(data.date)
                    ? LinearGradient(
                        colors: [Color.customBurgundy, Color.customBurgundy.opacity(Constraint.Opacity.high)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    : LinearGradient(
                        colors: [Color.customBurgundy.opacity(Constraint.Opacity.high), Color.customBurgundy.opacity(Constraint.Opacity.medium)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(isCurrentPeriod(data.date) ? 1.0 : 0.7)
            }

            let uniqueValues = Array(Set(animatedData.map(\.amount)))
                .filter { $0 > 0 }
                .sorted()
            
            ForEach(Array(uniqueValues.enumerated()), id: \.offset) { index, value in
                RuleMark(y: .value("Amount", value))
                    .foregroundStyle(.customRichBlack.opacity(Constraint.Opacity.low))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: index == uniqueValues.count - 1 ? [] : [3]))
            }
        }
        .padding(.horizontal, Constraint.padding)
        .chartYAxis {
            AxisMarks(values: .automatic) {
                AxisValueLabel()
                    .font(.caption2)
                    .foregroundStyle(.customRichBlack)
            }
        }
        .preferredColorScheme(.light)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(selectedTimeFrame == .daily ? .caption2 : .system(size: 10))
                    .foregroundStyle(.customRichBlack.opacity(Constraint.Opacity.medium))
            }
        }
        .preferredColorScheme(.light)
    }

    private func isCurrentPeriod(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
    
        switch selectedTimeFrame {
        case .daily:
            return calendar.isDate(date, inSameDayAs: today)
        case .weekly:
            return calendar.isDate(date, equalTo: today, toGranularity: .weekOfYear)
        case .monthly:
            return calendar.isDate(date, equalTo: today, toGranularity: .month)
        }
    }

    private func animateChart() {
        /// Reset animations
        showChart = false
        animatedData = []
        
        let newData = chartData
        
        /// Progressive animation sequence
        withAnimation(.smooth(duration: 0.2)) {
            showChart = true
        }
        
        /// Animate chart data after initial appearance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.smooth(duration: 0.6)) {
                animatedData = newData
            }
        }
    }
    
    // MARK: - Data Generation Methods
    private func generateDailyData() -> [ExpenseChartData] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        var data: [ExpenseChartData] = []

        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) ?? today
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"
            let dayName = dayFormatter.string(from: date)
            let dayExpenses = appState.expenseViewModels.filter { expense in
                calendar.isDate(expense.date, inSameDayAs: date)
            }
            let totalAmount = dayExpenses.reduce(0) { $0 + $1.amount }
            data.append(ExpenseChartData(
                period: dayName,
                amount: totalAmount,
                date: date
            ))
        }
        return data
    }

    private func generateWeeklyData() -> [ExpenseChartData] {
        let calendar = Calendar.current
        let today = Date()
        var data: [ExpenseChartData] = []

        for i in 0..<12 {
            let date = calendar.date(byAdding: .weekOfYear, value: -i, to: today) ?? today
            let weekFormatter = DateFormatter()
            weekFormatter.dateFormat = "d"
            let weekName = weekFormatter.string(from: date)
            let weekExpenses = appState.expenseViewModels.filter { expense in
                calendar.isDate(expense.date, equalTo: date, toGranularity: .weekOfYear)
            }
            let totalAmount = weekExpenses.reduce(0) { $0 + $1.amount }
            data.append(ExpenseChartData(
                period: weekName,
                amount: totalAmount,
                date: date
            ))
        }
        return data
    }

    private func generateMonthlyData() -> [ExpenseChartData] {
        let calendar = Calendar.current
        let today = Date()
        var data: [ExpenseChartData] = []

        for i in 0..<12 {
            let date = calendar.date(byAdding: .month, value: -i, to: today) ?? today
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM"
            let monthName = monthFormatter.string(from: date)
            let monthExpenses = appState.expenseViewModels.filter { expense in
                calendar.isDate(expense.date, equalTo: date, toGranularity: .month)
            }
            let totalAmount = monthExpenses.reduce(0) { $0 + $1.amount }
            data.append(ExpenseChartData(
                period: monthName,
                amount: totalAmount,
                date: date
            ))
        }
        return data
    }
}
