import SwiftUI
import Charts

struct LineChartView: View {
    @Binding var data: [LineChartItem]
    var totalRevenue: Double {
        data.reduce(0) { $0 + $1.getRevenue(goalMoneySpent: goalMoneySpent) }
    }
    var currency: String { data.first?.currency ?? "USD" }
    @Binding var goalMoneySpent: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(totalRevenue, specifier: "%.2f")\(data.first?.currencySymbol ?? "")")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.customLight)
                .padding(.top, 8)
                .padding(.leading, 16)
            animatedChart()
        }
        .background(.customDarkBlue)
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
            ForEach(data) { item in
                BarMark(
                    x: .value("Days", item.date, unit: .day),
                    y: .value("Balances", item.animate ? item.getRevenue(goalMoneySpent: goalMoneySpent) : 0)
                )
                .foregroundStyle(.customGreen.gradient)
            }
        }
        .frame(maxHeight: 250)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.customLight.shadow(.drop(radius: 2)))
        )
    }

    func animateChart() {
        for (index, _) in data.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                withAnimation(.easeIn(duration: 0.8)) {
                    data[index].animate = true
                }
            }
        }
    }
}


#Preview {
    LineChartView(data: .constant([]), goalMoneySpent: .constant(0))
}
