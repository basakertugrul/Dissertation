import SwiftUI
import Charts

struct LineChartView: View {
    @Binding var data: [LineChartItem]
    @Binding var goalMoneySpent: Double
    var currency: String { data.first?.currency ?? "USD" }

    var body: some View {
        VStack(alignment: .leading) {
            animatedChart()
        }
        .padding()
        .onAppear {
            animateChart()
        }
        .onChange(of: data) {
            animateChart()
        }
    }

    func animatedChart() -> some View {
        Chart {
            ForEach(data, id: \.id) { item in
                BarMark(
                    x: .value("Days", item.date, unit: .day),
                    y: .value("Expenses", item.animate ? item.getRevenue(goalMoneySpent: goalMoneySpent) : 0)
                )
                .foregroundStyle(item.getRevenue(goalMoneySpent: goalMoneySpent) >= 0 ? .customOliveGreen : .customBurgundy)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.formatted(.dateTime.month().day()))
                            .foregroundColor(.customRichBlack)
                    }
                }
                AxisTick()
                    .foregroundStyle(.customRichBlack)
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.3))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    Text("£\(value.as(Double.self) ?? 0, specifier: "%.0f")")
                        .foregroundColor(.customRichBlack)
                }
                AxisTick()
                    .foregroundStyle(.customRichBlack)
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.3))
            }
        }
        .frame(maxHeight: Constraint.regularImageSize)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constraint.cornerRadius)
                .fill(.customWhiteSand.shadow(.drop(radius: Constraint.shadowRadius)))
        )
    }

    func animateChart() {
        let duration: Double = (1.0 / Double(data.count))
        for (index, _) in data.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * duration) {
                withAnimation(.easeIn(duration: 0.8)) {
                    data[index].animate = true
                }
            }
        }
    }
}
