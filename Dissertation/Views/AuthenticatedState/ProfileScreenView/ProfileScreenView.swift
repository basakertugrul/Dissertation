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
    @State var showingProfileDataAlert = false
    @State var showingDeleteAccountAlert = false // New state for account deletion

    var title: AttributedString = {
        var string = AttributedString.init(stringLiteral: NSLocalizedString("profile", comment: ""))
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
                .padding([.top, .horizontal], Constraint.padding)
                .padding(.bottom, Constraint.largePadding)
            }

            ScrollView {
                VStack(spacing: Constraint.padding) {
                    profileCard
                    budgetCard
                    expenseChartCard
                    expenseDataCard
                    settingsGroups
                    logoutButton
                    deleteAccountButton
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
        .showComingSoonAlert(isPresented: $showingProfileDataAlert, buttonAction: { withAnimation(.smooth) {
            showingProfileDataAlert = false
        } })
        .showDeleteAccountConfirmationAlert(isPresented: $showingDeleteAccountAlert, onTap: appState.deleteAccount)
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
            let subject = NSLocalizedString("feedback_subject", comment: "")
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let iOSVersion = UIDevice.current.systemVersion
            
            let body = """
        \(NSLocalizedString("feedback_body_greeting", comment: ""))
        
        \(NSLocalizedString("feedback_body_message", comment: ""))
        
        \(NSLocalizedString("feedback_body_placeholder", comment: ""))
        
        \(NSLocalizedString("feedback_body_separator", comment: ""))
        \(NSLocalizedString("app_version_label", comment: "")) \(appVersion)
        \(NSLocalizedString("ios_version_label", comment: "")) \(iOSVersion)
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
            NSLocalizedString("hi_there", comment: ""),
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
                            NSLocalizedString("daily_budget", comment: ""),
                            font: .bodySmallBold,
                            color: .customRichBlack
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    CustomTextView.currency(appState.dailyBalance ?? .zero, font: .titleMediumBold, color: .customOliveGreen)
                }
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.customOliveGreen)
                    .font(.system(size: Constraint.largeIconSize))
            }
        }
        .addLayeredBackground(.customOliveGreen.opacity(Constraint.Opacity.low), style: .card(isColorFilled: true))
    }
    
    // MARK: - New Expense Chart Card
    private var expenseChartCard: some View {
        ExpenseChartView()
            .environmentObject(appState)
    }
    
    // MARK: - Expense Data Card
    private var expenseDataCard: some View {
        VStack(alignment: .leading, spacing: Constraint.largePadding) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.customOliveGreen)
                    .font(.body)
                
                CustomTextView(
                    NSLocalizedString("spending_overview", comment: ""),
                    font: .bodyLargeBold,
                    color: .customRichBlack
                )
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .foregroundColor(.customOliveGreen)
                    .font(.body)
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Constraint.padding), count: 2),
                spacing: Constraint.padding
            ) {
                expenseStatCard(
                    NSLocalizedString("todays_budget", comment: ""),
                    value: "\(getCurrencySymbol())\(appState.calculatedBalance)",
                    icon: "list.bullet.rectangle.fill",
                    color: .customOliveGreen
                )
                expenseStatCard(
                    NSLocalizedString("total_spent", comment: ""),
                    value: "\(getCurrencySymbol())\(appState.totalExpenses)",
                    icon: "banknote.fill",
                    color: .customBurgundy
                )
                expenseStatCard(
                    NSLocalizedString("daily_average", comment: ""),
                    value: "\(getCurrencySymbol())\(appState.formattedAverageDaily)",
                    icon: "calendar.badge.clock",
                    color: .customGold
                )
                expenseStatCard(
                    NSLocalizedString("days_tracked", comment: ""),
                    value: "\(appState.daysSinceStart)",
                    icon: "clock.fill",
                    color: .customRichBlack
                )
            }
        }
        .addLayeredBackground(.customOliveGreen.opacity(Constraint.Opacity.low), style: .card(isColorFilled: true))
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
            settingsGroup(NSLocalizedString("settings_support", comment: ""), items: [
                ("bell.badge.fill", NSLocalizedString("notifications", comment: ""), NSLocalizedString("budget_alerts_reminders", comment: ""), .customBurgundy, {
                    withAnimation(.smooth) {
                        showingProfileDataAlert = true
                    }
                    HapticManager.shared.trigger(.navigation)
                    appState.manageNotifications()
                }),
                ("square.and.arrow.up.fill", NSLocalizedString("export_data", comment: ""), NSLocalizedString("download_expense_history", comment: ""), .customRichBlack, {
                    HapticManager.shared.trigger(.buttonTap)
                    appState.exportExpenseData()
                }),
                ("lock.shield.fill", NSLocalizedString("privacy_security", comment: ""), NSLocalizedString("manage_data_protection", comment: ""), .customOliveGreen, {
                    HapticManager.shared.trigger(.navigation)
                    withAnimation(.smooth) {
                        showingPrivacyPolicyAlert = true
                    }
                }),
                ("envelope.badge.fill", NSLocalizedString("send_feedback", comment: ""), NSLocalizedString("help_improve_app", comment: ""), .customBurgundy, {
                    HapticManager.shared.trigger(.navigation)
                    withAnimation(.smooth) {
                        showingsendFeedbackAlert = true
                    }
                }),
                ("star.circle.fill", NSLocalizedString("rate_fundbud", comment: ""), NSLocalizedString("share_experience", comment: ""), .customRichBlack, {
                    HapticManager.shared.trigger(.navigation)
                    withAnimation(.smooth) {
                        showingAppRateAlert = true
                    }
                }),
                ("doc.text.fill", NSLocalizedString("legal_information", comment: ""), NSLocalizedString("terms_privacy_licenses", comment: ""), .customOliveGreen, {
                    HapticManager.shared.trigger(.navigation)
                    withAnimation(.smooth) {
                        showingLegalInfoAlert = true
                    }
                })
            ])
        }
    }

    // MARK: - Delete Account Button
    private var deleteAccountButton: some View {
        Button {
            HapticManager.shared.trigger(.warning)
            showingDeleteAccountAlert = true
        } label: {
            HStack(spacing: Constraint.padding) {
                Image(systemName: "trash.circle.fill")
                    .foregroundColor(.customBurgundy)
                    .font(.body)
                
                CustomTextView(
                    NSLocalizedString("delete_account", comment: ""),
                    font: .bodySmallBold,
                    color: .customBurgundy
                )
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .addLayeredBackground(.customBurgundy, style: .card(isColorFilled: false))
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
                    NSLocalizedString("sign_out", comment: ""),
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
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.customGold)
                    .font(.body)
                
                CustomTextView(
                    title,
                    font: .bodyLargeBold,
                    color: .customRichBlack
                )
                
                Spacer()
                
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.customGold)
                    .font(.body)
            }
            
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
        .addLayeredBackground(.customGold.opacity(Constraint.Opacity.low), style: .card(isColorFilled: false))
    }
    
    @ViewBuilder
    private func settingRow(icon: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Constraint.regularPadding) {
                ZStack {
                    RoundedRectangle(cornerRadius: Constraint.regularCornerRadius)
                        .fill(color)
                        .frame(width: Constraint.extremeIconSize, height: Constraint.extremeIconSize)
                    
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
