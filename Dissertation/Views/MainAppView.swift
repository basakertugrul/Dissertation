import SwiftUI
import CoreData

// MARK: - Main App View
struct MainAppView: View {
    @Environment(\.managedObjectContext) private var expenseModelContext

    @FetchRequest(
        entity: ExpenseModel.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExpenseModel.date, ascending: false)],
        animation: .smooth
    )
    private var expenses: FetchedResults<ExpenseModel>
    @State private var expenseViewModels: [ExpenseViewModel] = []

    @State private var isShowingItemSheet: Bool = false
    @State private var expenseToEdit: ExpenseViewModel?

    @State var targetSpending: Double? = 40.0  // Default value for preview
    @State private var selectedTab: Int = 0

    // MARK: – Body
    var body: some View {
        // Content
        VStack(spacing: 0) {
            // Header with logo and add button
            HStack {
                switch selectedTab {
                case 0:
                    Text("DAILY")
                        .font(.system(size: 22, weight: .light))
                        .tracking(1)
                        .foregroundColor(Color.whiteSand.opacity(0.7))
                    Text("BALANCE")
                        .font(.system(size: 22, weight: .bold))
                        .tracking(1)
                        .foregroundColor(Color.whiteSand)
                case 1:
                    Text("EXPENSES")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.whiteSand)
                default:
                    Text("DAILY")
                        .font(.system(size: 22, weight: .light))
                        .tracking(1)
                        .foregroundColor(Color.whiteSand.opacity(0.7))
                    Text("BALANCE")
                        .font(.system(size: 22, weight: .bold))
                        .tracking(1)
                        .foregroundColor(Color.whiteSand)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
            
            if selectedTab == 0 {
                // Balance screen content
                BalanceScreenView(
                    expenses: expenseViewModels,
                    dailyBalance: targetSpending ?? 0.0,
                    showAddExpenseSheet: $isShowingItemSheet
                )
            } else {
                // Expenses screen content
                ExpensesScreenView(
                    expenses: $expenseViewModels,
                    expenseToEdit: $expenseToEdit
                )
            }
            
            Spacer()
            
            // Custom tab bar
            CustomTabBar(
                selectedTab: $selectedTab,
                showAddExpenseSheet: $isShowingItemSheet,
                targetSpending: targetSpending
            )
        }
        .background(
            selectedTab == 0
                ? targetSpending == nil ? Color.burgundy : Color.oliveGreen
                : Color.burgundy
        )
        .sheet(item: .init(get: { expenseToEdit }, set: { _ in })) { expense in
            UpdateExpenseSheet(expense: expense)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $isShowingItemSheet) {
            AddExpenseSheet()
                .presentationDetents([.medium])
        }
        .onAppear {
            expenseViewModels = expenses.map(ExpenseViewModel.init(from:))
            targetSpending = DataController.shared.fetchTargetSpendingMoney()
        }
        .onReceive(
            NotificationCenter.default
                .publisher(
                    for: .NSManagedObjectContextObjectsDidChange,
                    object: expenseModelContext
                )
        ) { _ in
            expenseViewModels = expenses.map(ExpenseViewModel.init(from:))
        }
        .onReceive(
            NotificationCenter.default.publisher(for: Notification.Name("ExpenseUpdated"))
        )  { _ in
            let newExpenses = DataController.shared.fetchExpenses()
            expenseViewModels = newExpenses
        }
        .onReceive(
            NotificationCenter.default.publisher(for: Notification.Name("TargetSpendingMoneyUpdated"))
        )  { _ in
            targetSpending = DataController.shared.fetchTargetSpendingMoney()
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showAddExpenseSheet: Bool
    var targetSpending: Double?
    
    var body: some View {
        HStack {
            // Charts tab
            Button(action: {
                selectedTab = 0
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == 0 ? Color.whiteSand : Color.whiteSand.opacity(0.5))
                    
                    if selectedTab == 0 {
                        Circle()
                            .fill(Color.whiteSand)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(width: 60, height: 50)
            }
            
            Spacer()
            
            // Center add button (remove non-central add buttons)
            Button(action: {
                showAddExpenseSheet = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.burgundy)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(Color.whiteSand)
                }
            }
            .offset(y: -20)
            .disabled(targetSpending == nil)

            Spacer()

            // Expenses tab
            Button(action: {
                selectedTab = 1
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == 1 ? Color.whiteSand : Color.whiteSand.opacity(0.5))
                    
                    if selectedTab == 1 {
                        Circle()
                            .fill(Color.whiteSand)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(width: 60, height: 50)
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .background(
            // Background
            Rectangle()
                .fill(Color.richBlack)
                .ignoresSafeArea()
        )
    }
}
