import SwiftUI

// MARK: - Profile Actions Protocol
protocol ProfileActionsDelegate: AnyObject {
    func editBudget(currentAmount: Double)
    func manageNotifications()
    func exportExpenseData()
    func managePrivacySettings()
    func sendFeedback()
    func rateApp()
    func showLegalInfo()
    func signOut()
}

// MARK: - Expense Data Info
struct ExpenseDataInfo {
    let totalExpenses: Int
    let totalAmount: Double
    let oldestExpenseDate: Date?
    let averageDailySpending: Double
    
    var formattedTotalAmount: String {
        "£\(String(format: "%.2f", totalAmount))"
    }
    
    var daysSinceFirstExpense: Int {
        guard let oldestDate = oldestExpenseDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: oldestDate, to: Date()).day ?? 0
    }
    
    var formattedAverageDaily: String {
        "£\(String(format: "%.2f", averageDailySpending))"
    }
}

// MARK: - Profile Screen
struct ProfileScreen: View {
    var username: String
    var subtitle: String
    @Binding var dailyBudget: Double
    @State var showingBudgetSheet = false
    @State var showingLogoutAlert = false
    

    init(
        username: String,
        dailyBudget: Binding<Double>,
        delegate: ProfileActionsDelegate
    ) {
        self.username = username
        self._dailyBudget = dailyBudget
        self.delegate = delegate
        self.subtitle = "Hi " + (username.split(separator: " ").first ?? "") + "!"
    }

    var title: AttributedString = {
        var string = AttributedString.init(stringLiteral: "PROFILE")
        string.foregroundColor = .customBurgundy
        string.font = TextFonts.titleSmallBold.font
        return string
    }()

    // Sample expense data - replace with your actual data
    @State private var expenseData = ExpenseDataInfo(
        totalExpenses: 127,
        totalAmount: 2456.78,
        oldestExpenseDate: Calendar.current.date(byAdding: .day, value: -45, to: Date()),
        averageDailySpending: 18.50
    )
    
    weak var delegate: ProfileActionsDelegate?
    
    var body: some View {
        VStack(spacing: .zero) {
            CustomNavigationBarTitleView(title: title)
            ScrollView {
                VStack(spacing: Constraint.largePadding) {
                    profileCard
                    budgetCard
                    expenseDataCard
                    settingsGroups
                    logoutButton
                }
                .padding(Constraint.padding)
            }
        }
        .background(.customWhiteSand)
        .showDailyAllowanceSheet(
            isPresented: $showingBudgetSheet,
            currentAmount: dailyBudget
        ) {
            withAnimation {
                showingBudgetSheet = false
            }
            dailyBudget = $0
            delegate?.editBudget(currentAmount: $0)
        }
        .showLogOutConfirmationAlert(
            isPresented: $showingLogoutAlert,
            buttonAction: {
                delegate?.signOut()
                withAnimation(.smooth) {
                    showingLogoutAlert = false
                }
            },
            secondaryButtonAction: {
                withAnimation(.smooth) {
                    showingLogoutAlert = false
                }
        })
    }
    
    // MARK: - Profile Card
    private var profileCard: some View {
        let initials = username.components(separatedBy: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()

        return HStack(spacing: Constraint.padding) {
            ZStack {
                // Gradient background with glow effect
                Circle()
                    .fill(.customBurgundy)
                    .shadow(color: .black.opacity(Constraint.Opacity.low), radius: Constraint.shadowRadius)
                    .frame(width: Constraint.regularImageSize/3, height: Constraint.regularImageSize/3)
                
                CustomTextView(initials, font: .titleSmallBold)
            }
            
            CustomTextView(subtitle, font: .titleSmall, color: .customBurgundy)
            Spacer()
        }
    }

    // MARK: - Budget Card
    private var budgetCard: some View {
        Button {
            showingBudgetSheet = true
        } label: {
            HStack(spacing: Constraint.largePadding) {
                VStack(alignment: .leading, spacing: Constraint.smallPadding) {
                    HStack(spacing: Constraint.smallPadding) {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.customOliveGreen)
                            .font(.body)
                        
                        CustomTextView(
                            "Daily Budget",
                            font: .bodySmallBold,
                            color: .customRichBlack
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    CustomTextView.currency(dailyBudget, font: .titleLarge, color: .customOliveGreen)
                }
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.customOliveGreen)
                    .font(.system(size: Constraint.largeIconSize))
            }
        }
        .addLayeredBackground(.customOliveGreen.opacity(Constraint.Opacity.low), style: .card(isColorFilled: true))
    }
    
    // MARK: - Expense Data Card
    private var expenseDataCard: some View {
        VStack(alignment: .leading, spacing: Constraint.largePadding) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.customGold)
                    .font(.body)
                
                CustomTextView(
                    "Spending Overview",
                    font: .bodyLargeBold,
                    color: .customRichBlack
                )
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .foregroundColor(.customGold)
                    .font(.body)
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Constraint.padding), count: 2),
                spacing: Constraint.padding
            ) {
                expenseStatCard("Total Spent", value: expenseData.formattedTotalAmount, icon: "banknote.fill", color: .customBurgundy)
                expenseStatCard("Transactions", value: "\(expenseData.totalExpenses)", icon: "list.bullet.rectangle.fill", color: .customOliveGreen)
                expenseStatCard("Daily Average", value: expenseData.formattedAverageDaily, icon: "calendar.badge.clock", color: .customGold)
                expenseStatCard("Days Tracked", value: "\(expenseData.daysSinceFirstExpense)", icon: "clock.fill", color: .customRichBlack)
            }
        }
        .addLayeredBackground(.customGold.opacity(Constraint.Opacity.low), style: .card(isColorFilled: true))
    }
    
    @ViewBuilder
    private func expenseStatCard(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: Constraint.smallPadding) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.body)
            
            CustomTextView(
                value,
                font: .bodySmallBold,
                color: .customRichBlack
            )
            
            CustomTextView(
                title,
                font: .labelMedium,
                color: .customRichBlack.opacity(Constraint.Opacity.medium)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(Constraint.regularPadding)
        .background(.white.opacity(Constraint.Opacity.medium))
        .cornerRadius(Constraint.regularCornerRadius)
    }
    
    // MARK: - Settings Groups
    private var settingsGroups: some View {
        VStack(spacing: Constraint.largePadding) {
            settingsGroup("App Settings", items: [
                ("bell.badge.fill", "Notifications", "Budget alerts & reminders", .customBurgundy, { delegate?.manageNotifications() }),
                ("square.and.arrow.up.fill", "Export Data", "Download expense history", .customOliveGreen, { delegate?.exportExpenseData() }),
                ("lock.shield.fill", "Privacy & Security", "Manage your data protection", .customRichBlack, { delegate?.managePrivacySettings() })
            ])

            settingsGroup("Support & Info", items: [
                ("envelope.badge.fill", "Send Feedback", "Help us improve the app", .customOliveGreen, { delegate?.sendFeedback() }),
                ("star.circle.fill", "Rate BudgetMate", "Share your experience", .customGold, { delegate?.rateApp() }),
                ("doc.text.fill", "Legal Information", "Terms, privacy & licenses", .customRichBlack, { delegate?.showLegalInfo() })
            ])
        }
    }
    
    // MARK: - Logout Button
    private var logoutButton: some View {
        Button { showingLogoutAlert = true } label: {
            HStack(spacing: Constraint.padding) {
                Image(systemName: "power.circle.fill")
                    .foregroundColor(.customBurgundy)
                    .font(.body)
                
                CustomTextView(
                    "Sign Out",
                    font: .bodySmallBold,
                    color: .customBurgundy
                )
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .addLayeredBackground(.customBurgundy.opacity(Constraint.Opacity.medium), style: .card(isColorFilled: false))
    }
    
    // MARK: - Settings Group Helper
    @ViewBuilder
    private func settingsGroup(_ title: String, items: [(String, String, String, Color, () -> Void)]) -> some View {
        VStack(alignment: .leading, spacing: Constraint.largePadding) {
            CustomTextView(
                title,
                font: .titleSmallBold,
                color: .customRichBlack
            )
            
            VStack(spacing: Constraint.padding) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    settingRow(
                        icon: item.0,
                        title: item.1,
                        subtitle: item.2,
                        color: item.3,
                        action: item.4
                    )
                }
            }
        }
        .addLayeredBackground(.customWhiteSand, style: .card(isColorFilled: false))
    }
    
    @ViewBuilder
    private func settingRow(icon: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Constraint.regularPadding) {
                ZStack {
                    RoundedRectangle(cornerRadius: Constraint.regularCornerRadius)
                        .fill(color)
                        .frame(width: Constraint.extremeIconSize, height: Constraint.extremeIconSize)
//                        .shadow(color: color.opacity(Constraint.Opacity.low), radius: Constraint.tinyPadding)
                    
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: Constraint.tinyPadding) {
                    CustomTextView(
                        title,
                        font: .bodySmallBold,
                        color: .customRichBlack
                    )
                    
                    CustomTextView(
                        subtitle,
                        font: .labelMedium,
                        color: .customRichBlack.opacity(Constraint.Opacity.medium)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(.customRichBlack.opacity(Constraint.Opacity.low))
                    .font(.body)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        ProfileScreen(
            username: "John Adam",
            dailyBudget: .constant(20),
            delegate: AppStateManager.shared
        )
    }
}
