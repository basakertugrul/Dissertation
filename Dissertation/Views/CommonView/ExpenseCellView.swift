import SwiftUI
import SwiftData

struct ExpenseCellView: View {
    let expense: ExpenseViewModel
    var body: some View {
        HStack {
            Text(expense.date, format: .dateTime.month(.abbreviated).day())
                .frame(width: 70, alignment: .leading)
            Text (expense.name)
            Spacer ()
            Text(expense.amount, format: .currency (code: "GBP"))
        }
    }
}
