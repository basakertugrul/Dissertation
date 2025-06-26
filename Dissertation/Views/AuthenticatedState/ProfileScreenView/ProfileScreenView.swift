import SwiftUI
import StoreKit

// MARK: - Profile Actions Protocol
protocol ProfileActionsDelegate: AnyObject {
    func editBudget(currentAmount: Double)
    func manageNotifications()
    func exportExpenseData()
    func signOut()
}

// MARK: - Profile Screen
struct ProfileScreen: View {
    @EnvironmentObject var appState: AppStateManager

    /// UI related
    @State var showingBudgetSheet = false
    @State var showingLogoutAlert = false
    @State var showingAppRateAlert = false
    @State var showingLegalInfoAlert = false
    @State var showingsendFeedbackAlert = false
    @State var showingPrivacyPolicyAlert = false
    @State var showingExportDataAlert = false

    var title: AttributedString = {
        var string = AttributedString.init(stringLiteral: "PROFILE")
        string.foregroundColor = .customBurgundy
        string.font = TextFonts.titleSmallBold.font
        return string
    }()
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                CustomNavigationBarTitleView(title: title)
                Spacer()
                Button {
                    HapticManager.shared.trigger(.cancel)
                    withAnimation(.smooth) {
                        appState.isProfileScreenOpen = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundColor(.customBurgundy.opacity(Constraint.Opacity.high))
                        .frame(width: 32, height: 32)
                }
                .padding(Constraint.padding)
            }

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
            currentAmount: appState.dailyBalance ?? .zero
        ) {
            withAnimation {
                showingBudgetSheet = false
            }
            appState.editBudget(currentAmount: $0)
        }
        .showLogOutConfirmationAlert(
            isPresented: $showingLogoutAlert,
            buttonAction: {
                appState.signOut()
                withAnimation(.smooth) {
                    showingLogoutAlert = false
                }
            },
            secondaryButtonAction: {
                withAnimation(.smooth) {
                    showingLogoutAlert = false
                }
            })
        .showAppRateConfirmationAlert(isPresented: $showingAppRateAlert) { rateApp() }
        .showLegalInformationAlert(isPresented: $showingLegalInfoAlert)
        .showSendFeedbackConfirmationAlert(isPresented: $showingsendFeedbackAlert, onTap: sendFeedback)
        .showPrivacySecurityAlert(isPresented: $showingPrivacyPolicyAlert)
        .showExportDataConfirmationAlert(isPresented: $showingExportDataAlert, onTap: exportData)
    }

    private func rateApp() {
        HapticManager.shared.trigger(.success)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
               AppStore.requestReview(in: scene)
           }
    }
    
    private func exportData() {
        HapticManager.shared.trigger(.buttonTap)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
               AppStore.requestReview(in: scene)
           }
    }

    private func sendFeedback() {
        HapticManager.shared.trigger(.navigation)
        if UIApplication.shared.canOpenURL(URL(string: "mailto:")!) {
            let email = "fundBud2025@gmail.com"
            let subject = "FundBud Feedback - iOS App"
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let iOSVersion = UIDevice.current.systemVersion
            
            let body = """
        Hi FundBud team,
        
        I'd like to share feedback about the app:
        
        [Please write your feedback here]
        
        ---
        App Version: \(appVersion)
        iOS Version: \(iOSVersion)
        """
            
            var components = URLComponents()
            components.scheme = "mailto"
            components.path = email
            components.queryItems = [
                URLQueryItem(name: "subject", value: subject),
                URLQueryItem(name: "body", value: body)
            ]
            
            if let url = components.url {
                UIApplication.shared.open(url)
            }
            
        }
    }
    
    // MARK: - Profile Card
    private var profileCard: some View {
        CustomTextView(
            (
                "Hi there!"
            ),
            font: .titleMediumBold,
            color: .customBurgundy
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Budget Card
    private var budgetCard: some View {
        Button {
            HapticManager.shared.trigger(.edit)
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
                    
                    CustomTextView.currency(appState.dailyBalance ?? .zero, font: .titleLarge, color: .customOliveGreen)
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
                expenseStatCard(
                    "Today's Budget",
                    value: "\(appState.calculatedBalance)",
                    icon: "list.bullet.rectangle.fill",
                    color: .customOliveGreen
                )
                expenseStatCard(
                    "Total Spent",
                    value: "£\(appState.totalExpenses)",
                    icon: "banknote.fill",
                    color: .customBurgundy
                )
                expenseStatCard(
                    "Daily Average",
                    value: "£\(appState.formattedAverageDaily)",
                    icon: "calendar.badge.clock",
                    color: .customGold
                )
                expenseStatCard(
                    "Days Tracked",
                    value: "\(appState.daysSinceStart)",
                    icon: "clock.fill",
                    color: .customRichBlack
                )
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
            settingsGroup("Settings & Support", items: [
                ("bell.badge.fill", "Notifications", "Budget alerts & reminders", .customBurgundy, {
                    HapticManager.shared.trigger(.navigation)
                    appState.manageNotifications()
                }),
                ("square.and.arrow.up.fill", "Export Data", "Download expense history", .customOliveGreen, {
                    HapticManager.shared.trigger(.buttonTap)
                    appState.exportExpenseData()
                }),
                ("lock.shield.fill", "Privacy & Security", "Manage your data protection", .customRichBlack, {
                    HapticManager.shared.trigger(.navigation)
                    withAnimation(.smooth) {
                        showingPrivacyPolicyAlert = true
                    }
                }),
                ("envelope.badge.fill", "Send Feedback", "Help us improve the app", .customOliveGreen, {
                    HapticManager.shared.trigger(.navigation)
                    withAnimation(.smooth) {
                        showingsendFeedbackAlert = true
                    }
                }),
                ("star.circle.fill", "Rate FundBud", "Share your experience", .customGold, {
                    HapticManager.shared.trigger(.navigation)
                    withAnimation(.smooth) {
                        showingAppRateAlert = true
                    }
                }),
                ("doc.text.fill", "Legal Information", "Terms, privacy & licenses", .customRichBlack, {
                    HapticManager.shared.trigger(.navigation)
                    withAnimation(.smooth) {
                        showingLegalInfoAlert = true
                    }
                })
            ])
        }
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button {
            HapticManager.shared.trigger(.warning)
            showingLogoutAlert = true
        } label: {
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
