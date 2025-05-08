import SwiftUI

// MARK: - Expenses Screen
struct ExpensesScreenView: View {
    @Binding var expenses: [ExpenseViewModel]
    @Binding var expenseToEdit: ExpenseViewModel?
    
    var groupedExpenses: [String: [ExpenseViewModel]] {
        Dictionary(grouping: expenses) { expense in
            // Group by date
            let dateFormatter = DateFormatter()
            let calendar = Calendar(identifier: .iso8601)
            dateFormatter.dateFormat = "yyyy-MM-dd"

            if calendar.isDateInToday(expense.date) {
                return "TODAY"
            } else if calendar.isDateInYesterday(expense.date) {
                return "YESTERDAY"
            } else {
                return "EARLIER"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(groupedExpenses.keys.sorted(), id: \.self) { key in
                    if let expensesForDate = groupedExpenses[key] {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(key)
                                .font(.system(size: 14, weight: .medium))
                                .tracking(1)
                                .foregroundColor(Color.whiteSand.opacity(0.6))
                            
                            ForEach(expensesForDate) { expense in
                                ExpenseRow(expense: expense) {
                                    expenseToEdit = expense
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.whiteSand.opacity(0.03))
            .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        }
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

// MARK: - Helper Views
struct ExpenseItemView: View {
    let expense: ExpenseViewModel
    
    var body: some View {
        HStack {
            // Icon
            Circle()
                .fill(Color.richBlack.opacity(0.4))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "creditcard")
                        .font(.system(size: 16))
                        .foregroundColor(Color.whiteSand.opacity(0.8))
                )
            
            // Title
            Text(expense.name)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(Color.whiteSand)
            
            Spacer()
            
            // Amount and date
            VStack(alignment: .trailing, spacing: 4) {
                Text("-$\(expense.amount, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.whiteSand)
                Text(expense.getDateString())
                    .font(.system(size: 12))
                    .foregroundColor(Color.whiteSand.opacity(0.5))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.richBlack.opacity(0.4))
        .cornerRadius(12)
    }
}

struct ExpenseRow: View {
    let expense: ExpenseViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(expense.getDateString())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.whiteSand)
                
                Text(expense.name)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(Color.whiteSand)
                
                Spacer()
                
                Text("£\(expense.amount, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.whiteSand)
            }
            .padding(16)
            .background(Color.whiteSand.opacity(0.05))
            .cornerRadius(12)
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Rounded Corner Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
 //TODO: custombackground ekle her yere
