import SwiftUI
import CoreData

// MARK: - App Entry Point
@main
struct BudgetMateApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var appState = AppStateManager.shared
    let dataController = DataController.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.hasLoggedIn {
                    if appState.dailyBalance == .none {
                        BalanceEntranceView() { dailyAmount in
                            DataController.shared.saveTargetSpending(to: dailyAmount)
                            
                        } onTouchedBackground: {}
                    } else {
                        MainAppView()
                    }
                } else {
                    SignInView(isLoading: $appState.isLoading)
                }
            }
            .loadingOverlay($appState.isLoading)
            .environmentObject(appState)
            .environment(\.managedObjectContext, dataController.expenseModelContext)
            .onAppear(perform: setupApp)
            .onChange(of: scenePhase, { _, newValue in
                handleScenePhaseChange(newValue)
            })
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
