import SwiftUI
import SwiftData

struct UpdateExpenseSheet: View {
    @State var expense: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    var dateRange: ClosedRange<Date> {
        let now: Date = Date()
        let distantPast: Date = .distantPast
        return distantPast...now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField( "Expense Name", text: $expense.name)
                    DatePicker ("Date", selection: $expense.date, in: dateRange, displayedComponents: .date)
                        .tint(.customDarkBlue)
                    TextField("Value", value: $expense.amount, format: .currency (code: "GBP"))
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Update Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup (placement: .topBarLeading) {
                    Button ("Done") {
                        dismiss() // TODO: Does not get dismissed
                        DataController.shared.updateExpense(of: expense)
                    }
                }
            }
            .tint(.white)
        }
    }
}

#Preview {
    UpdateExpenseSheet(
        expense: .createWithPound(
            name: "dd",
            date: .now,
            amount: 20,
            createDate: .now
        )
    )
}
