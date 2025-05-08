import SwiftUI
import SwiftData

// MARK: - Color Extension
extension Color {
    static let oliveGreen = Color(hex: "828048")
    static let burgundy = Color(hex: "6A1A21")
    static let whiteSand = Color(hex: "F8ECD8")
    static let richBlack = Color(hex: "121212")
}

// Hex color helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Balance Screen
struct BalanceScreenView: View {
    let expenses: [ExpenseViewModel]
    let dailyBalance: Double
    @Binding var showAddExpenseSheet: Bool
    
    var daysSinceEarliest: Int {
        if let date = expenses.map({ $0.date }).min() {
            return daysTo(date: date) ?? .zero
        }
        return .zero
    }
    
    func daysTo(date: Date) -> Int? {
        let calendar = Calendar.current

        let finalDate = calendar.startOfDay(for: Date())
        let startDate = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: startDate, to: finalDate)
        return components.day
    }

    var totalExpenses: Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    var calculatedBalance: Double {
        return dailyBalance * Double(daysSinceEarliest) - totalExpenses
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Main balance section
            VStack(spacing: 8) {
                Text("CURRENT BALANCE")
                    .font(.system(size: 14, weight: .light))
                    .tracking(2)
                    .foregroundColor(Color.whiteSand.opacity(0.7))
                
                HStack(alignment: .lastTextBaseline) {
                    Text("$\(abs(calculatedBalance), specifier: "%.2f")")
                        .font(.system(size: 54, weight: .light))
                        .tracking(0.5)
                        .foregroundColor(Color.whiteSand)
                    
                    Text(calculatedBalance >= 0 ? "AVAILABLE" : "OVERDRAWN")
                        .font(.system(size: 14, weight: .light))
                        .tracking(2)
                        .foregroundColor(Color.whiteSand.opacity(0.6))
                        .padding(.leading, 8)
                }
                
                // Divider
                Rectangle()
                    .fill(Color.whiteSand.opacity(0.2))
                    .frame(height: 1)
                    .padding(.vertical, 16)
            }
            .padding(.top, 40)
            
            // Stats cards
            HStack(spacing: 12) {
                // Daily allowance
                VStack(alignment: .leading, spacing: 8) {
                    Text("DAILY ALLOWANCE")
                        .font(.system(size: 12, weight: .light))
                        .tracking(1.5)
                        .foregroundColor(Color.whiteSand.opacity(0.7))
                    
                    HStack {
                        Text("$\(dailyBalance, specifier: "%.2f")")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color.whiteSand)
                        
                        Spacer()
                        
                        // Edit button
                        Circle()
                            .fill(Color.whiteSand.opacity(0.1))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "pencil")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.whiteSand.opacity(0.7))
                            )
                    }
                }
                .padding(16)
                .background(Color.richBlack.opacity(0.7))
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
                
                // Days tracked
                VStack(alignment: .leading, spacing: 8) {
                    Text("DAYS TRACKED")
                        .font(.system(size: 12, weight: .light))
                        .tracking(1.5)
                        .foregroundColor(Color.whiteSand.opacity(0.7))
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(daysSinceEarliest)")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(Color.whiteSand)
                        
                        Text("since May 2")
                            .font(.system(size: 12))
                            .foregroundColor(Color.whiteSand.opacity(0.5))
                    }
                }
                .padding(16)
                .background(Color.richBlack.opacity(0.7))
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
            }
            
            // Total expenses card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(Color.burgundy.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "target")
                                .font(.system(size: 16))
                                .foregroundColor(Color.whiteSand)
                        )
                    
                    Spacer()
                    
                    Text("MONTHLY")
                        .font(.system(size: 12, weight: .light))
                        .tracking(1)
                        .foregroundColor(Color.whiteSand.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.richBlack.opacity(0.4))
                        .cornerRadius(8)
                }
                
                Text("TOTAL EXPENSES")
                    .font(.system(size: 12, weight: .light))
                    .tracking(1.5)
                    .foregroundColor(Color.whiteSand.opacity(0.7))
                
                Text("$\(totalExpenses, specifier: "%.2f")")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color.whiteSand)
            }
            .padding(16)
            .background(Color.richBlack.opacity(0.7))
            .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .customBackground(with: calculatedBalance <= 0 ? .burgundy : .oliveGreen)
    }
}
