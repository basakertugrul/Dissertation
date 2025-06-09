import SwiftUI
import CoreData
// TODO: check the number it should be with a dot: 99.44

// MARK: - App Entry Point
@main
struct BudgetMateApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var appState = AppStateManager()

    let dataController = DataController.shared

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(appState)
                .environment(\.managedObjectContext, dataController.expenseModelContext)
                .onAppear(perform: setupApp)
                .onChange(of: scenePhase, { _, newValue in
                    handleScenePhaseChange(newValue)
                })
//                .onAppear {
//                    dataController.resetTargetSpending()
//                    dataController.resetExpenses()
//                    dataController.resetTimeFrame()
//                }
        }
    }
}

// MARK: - App Setup & Event Handling
private extension BudgetMateApp {
    func setupApp() {
        appState.loadInitialData()
        setupNotificationObservers()
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        if phase == .background || phase == .inactive {
            dataController.save()
        }
    }

    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("ExpenseRefresh"),
            object: .none,
            queue: .main
        ) { _ in
            DispatchQueue.main.async {
                appState.refreshExpenses()
            }
        }

        NotificationCenter.default.addObserver(
            forName: Notification.Name("TargetSpendingMoneyUpdated"),
            object: .none,
            queue: .main
        ) { _ in
            DispatchQueue.main.async {
                appState.refreshDailyBalance()
            }
        }
    }
}

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    @Published var dailyBalance: Double = .zero
    @Published var expenseViewModels: [ExpenseViewModel] = []

    private let dataController = DataController.shared

    var daysSinceEarliest: Int {
        guard let earliestDate = expenseViewModels.map({ $0.date }).min() else {
            return 0
        }

        let calendar = Calendar.current
        return calendar.dateComponents([.day],
                                       from: calendar.startOfDay(for: earliestDate),
                                       to: calendar.startOfDay(for: Date())).day ?? 0
    }

    var totalExpenses: Double {
        expenseViewModels.reduce(0) { $0 + $1.amount }
    }

    var calculatedBalance: Double {
        dailyBalance * Double(daysSinceEarliest) - totalExpenses
    }

    func loadInitialData() {
        refreshDailyBalance()
        refreshExpenses()
    }

    func refreshDailyBalance() {
        dailyBalance = dataController.fetchTargetSpendingMoney() ?? 0
    }

    func refreshExpenses() {
        expenseViewModels = dataController.fetchExpenses()
    }
}
