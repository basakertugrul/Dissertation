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
                            switch DataController.shared.saveTargetSpending(to: dailyAmount) {
                            case .success:
                                appState.hasSavedDailyLimit = true
                            case let .failure(comingError):
                                appState.error = comingError
                            }
                            
                        } onTouchedBackground: {}
                            .showSavedDailyLimitAlert(
                                isPresented: $appState.hasSavedDailyLimit
                            )
                    } else {
                        MainAppView()
                    }
                } else {
                    SignInView()
                }
            }
            .showErrorAlert(
                isPresented: .init(get: {
                    appState.error != nil || appState.signInError != nil
                }, set: { _ in }),
                errorMessage:  appState.error?.errorDescription
                ?? appState.signInError?.errorDescription
                ?? "") {
                    appState.error = nil
                    appState.signInError = nil
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
        appState.getUserInfo()
        appState.loadInitialData()
        setupNotificationObservers()
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        if phase == .background || phase == .inactive {
            let _ = dataController.save() 
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

        NotificationCenter.default.addObserver(
            forName: Notification.Name("LoggedIn"),
            object: .none,
            queue: .main
        ) { _ in
            DispatchQueue.main.async {
                appState.getUserInfo()
                appState.refreshExpenses()
                appState.refreshDailyBalance()
            }
        }
    }
}
