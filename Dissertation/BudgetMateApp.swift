import SwiftUI
import CoreData

@main
struct BudgetMateApp: App {
    @Environment(\.scenePhase) var scenePhase
    let dataController = DataController.shared

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .onChange(of: scenePhase) { dataController.save() }
                .environment(\.managedObjectContext,
                              dataController.expenseModelContainer.viewContext)
                .environment(\.managedObjectContext,
                              dataController.targetSpendingModelContainer.viewContext)
//                .onAppear {
//                    dataController.resetTargetSpending()
//                    dataController.resetExpenses()
//                }
        }
    }
}

// TODO: check the number it should be with a dot: 99.44
