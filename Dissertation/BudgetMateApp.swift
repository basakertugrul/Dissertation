import SwiftUI
import CoreData

// MARK: - App Entry Point
@main
struct BudgetMateApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var appState = AppStateManager.shared
    
    @State var hasLoggedIn: Bool = false
    @State var isLoading: Bool = false

    let dataController = DataController.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasLoggedIn {
                    MainAppView()
                        .environmentObject(appState)
                        .environment(\.managedObjectContext, dataController.expenseModelContext)
                        .onAppear(perform: setupApp)
                        .onChange(of: scenePhase, { _, newValue in
                            handleScenePhaseChange(newValue)
                        })
                } else {
                    SignInView(isLoading: $isLoading)
                }
            }
            .loadingOverlay($isLoading)
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
