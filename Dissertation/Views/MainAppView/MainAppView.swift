import SwiftUI
import CoreData

// MARK: - Main App View
struct MainAppView: View {
    @EnvironmentObject private var appState: AppStateManager
    @Environment(\.managedObjectContext) private var expenseModelContext
    
    @FetchRequest(
        entity: ExpenseModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExpenseModel.date, ascending: false)],
        animation: .smooth
    )
    private var expenses: FetchedResults<ExpenseModel>

    /// UI State
    @State private var currentTab: CustomTabBarSection = .balance
    @State private var isShowingAddExpenseSheet: Bool = false
    @State private var expenseToEdit: ExpenseViewModel?
    @State private var willOpenCameraView: Bool = false
    @State private var showingAllowanceSheet: Bool = false

    var backgroundColor: Color {
        currentTab == .balance
        ? (appState.calculatedBalance >= 0 ? .customOliveGreen : .customBurgundy)
        : .customWhiteSand
    }

    var body: some View {
        VStack(spacing: .zero) {
            navigationSection
            contentSection
            tabBarSection
        }
        .ignoresSafeArea(.keyboard)
        .addCircledBackground(with: .customWhiteSand)
        .sheet(
            isPresented: $isShowingAddExpenseSheet,
            onDismiss: clearAddExpenseData
        ) {
            ModifyExpenseView(expenseToModify: .constant(.none))
        }
        .sheet(
            isPresented: .init(get: { expenseToEdit != .none }, set: { _ in }),
            onDismiss: clearEditExpenseData
        ) {
            ModifyExpenseView(expenseToModify: $expenseToEdit)
        }
        .sheet(isPresented: $willOpenCameraView) { cameraSheet }
        .showDailyAllowanceSheet(
            isPresented: $showingAllowanceSheet,
            currentAmount: appState.dailyBalance,
            onSave: { amount in
                DataController.shared.saveTargetSpending(to: amount)
            }
        )
        .onReceive(expenseContextPublisher, perform: handleExpenseContextChange)
    }
}

// MARK: - MainAppView Extensions
private extension MainAppView {
    var navigationSection: some View {
        CustomNavigationBarView(selectedTab: $currentTab)
    }

    @ViewBuilder
    var contentSection: some View {
        switch currentTab {
        case .balance:
            BalanceScreenView(
                expenses: $appState.expenseViewModels,
                dailyBalance: $appState.dailyBalance,
                totalExpenses: .init(get: {
                    appState.totalExpenses
                }, set: { _ in }),
                calculatedBalance: .init(get: {
                    appState.calculatedBalance
                }, set: { _ in }),
                timeFrame: DataController.shared.fetchTimeFrame(),
                backgroundColor: .init(get: {
                    backgroundColor
                }, set: { _ in}),
                showingAllowanceSheet: $showingAllowanceSheet,
                currentTab: $currentTab,
                startDay: $appState.startDate
            )

        case .expenses:
            ExpensesScreenView(
                expenses: $appState.expenseViewModels,
                onExpenseEdit: { expense in
                    DispatchQueue.main.async {
                        expenseToEdit = expense
                    }
                }
            )
        }
    }

    var tabBarSection: some View {
        CustomTabBar(
            selectedTab: $currentTab,
            showAddExpenseSheet: $isShowingAddExpenseSheet,
            targetSpending: appState.dailyBalance,
            willOpenCameraView: $willOpenCameraView
        )
    }

    var cameraSheet: some View {
        CameraView()
            .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Computed Properties & Handlers
private extension MainAppView {
    var expenseContextPublisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextObjectsDidChange,
            object: expenseModelContext
        )
    }

    func handleExpenseContextChange(_ notification: Notification) {
        appState.expenseViewModels = expenses.map(ExpenseViewModel.init(from:))
    }

    func clearAddExpenseData() {
        DispatchQueue.main.async {
            withAnimation {
                isShowingAddExpenseSheet = false
            }
        }
    }

    func clearEditExpenseData() {
        DispatchQueue.main.async {
            withAnimation {
                expenseToEdit = .none
            }
        }
    }
}
