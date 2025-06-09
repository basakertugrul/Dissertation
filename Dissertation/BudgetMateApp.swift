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
    @Published var dailyBalance: Double = 0
    @Published var expenseViewModels: [ExpenseViewModel] = []
    
    private let dataController = DataController.shared
     
    func loadInitialData() {
        /// For Report: they get called here and not timeframe cuz it's set to user defaults but this is set to database so more important. It can be handled from the app
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
