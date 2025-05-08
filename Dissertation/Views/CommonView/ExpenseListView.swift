import SwiftUI

struct ExpenseListView: View {
    @Binding var expenses: [ExpenseViewModel]
    @Binding var expenseToEdit: ExpenseViewModel?
    private let desiredOrder = ["Today", "Yesterday", "This Week", "This Month", "Last Month", "Older"]

    var body: some View {
        List {
            ForEach(desiredOrder, id: \.self) { section in
                if let expensesInSection = getListItems()[section], !expensesInSection.isEmpty {
                    Section(header: Text(section)) {
                        ForEach(expensesInSection) { expense in
                            ExpenseCellView(expense: expense)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteExpenses(of: expense)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.customRed)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        expenseToEdit = expense
                                    } label: {
                                        Label("Flag", systemImage: "rectangle.and.pencil.and.ellipsis")
                                    }
                                    .tint(.customOrange)
                                }
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
    }

    private func getListItems() -> [String: [ExpenseViewModel]] {
        var categorized: [String: [ExpenseViewModel]] = [:]
        let calendar = Calendar.current
        let now = Date()

        for expense in expenses {
            let date = expense.date
            if calendar.isDateInToday(date) {
                categorized["Today", default: []].append(expense)
            } else if calendar.isDateInYesterday(date) {
                categorized["Yesterday", default: []].append(expense)
            } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
                categorized["This Week", default: []].append(expense)
            } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
                categorized["This Month", default: []].append(expense)
            } else if let lastMonth = calendar.date(byAdding: .month, value: -1, to: now),
                        calendar.isDate(date, equalTo: lastMonth, toGranularity: .month) {
                categorized["Last Month", default: []].append(expense)
            } else {
                categorized["Older", default: []].append(expense)
            }
        }

        for key in categorized.keys {
            categorized[key]?.sort { $0.date > $1.date }
        }

        let desiredOrder = ["Today", "Yesterday", "This Week", "This Month", "Last Month", "Older"]
        var sortedCategorized: [String: [ExpenseViewModel]] = [:]
        for key in desiredOrder {
            if let items = categorized[key] {
                sortedCategorized[key] = items
            }
        }
        return sortedCategorized
    }

    private func deleteExpenses(of expense: ExpenseViewModel) {
        DataController.shared.deleteExpense(of: expense)
    }
}

#Preview {
    ExpenseListView(
        expenses: .constant([]),
        expenseToEdit: .constant(.none)
    )
}
