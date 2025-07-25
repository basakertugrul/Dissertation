import SwiftUI

struct ModifyExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismissView
    @EnvironmentObject var appStateManager: AppStateManager

    /// Optional expense to modify - .none means we're adding a new expense
    @Binding var expenseToModify: ExpenseViewModel?
    var startDay: Date

    @State private var expenseName: String = ""
    @State private var expenseAmount: Double = .zero
    @State private var expenseDate: Date = Date()
    @State private var showDeleteConfirmation: Bool = false
    
    @State private var isVisible: Bool = false

    /// Track if we're in edit mode
    private var isEditMode: Bool {
        return expenseToModify != .none
    }

    private var dateRange: ClosedRange<Date> {
        let now: Date = .now
        return startDay...now
    }

    /// Button text based on mode
    private var saveButtonText: String {
        return isEditMode ? NSLocalizedString("update", comment: "") : NSLocalizedString("save", comment: "")
    }

    /// Validation check
    private var isFormValid: Bool {
        expenseAmount > 0 && dateRange.contains(expenseDate)
    }

    var body: some View {
        ZStack {
            BackgroundView()
            
            if isVisible {
                ScrollView {
                    VStack(spacing: Constraint.extremePadding) {
                        HeaderView(isEditMode: isEditMode)
                        
                        FormFieldsView(
                            expenseName: $expenseName,
                            expenseAmount: $expenseAmount,
                            expenseDate: $expenseDate,
                            dateRange: dateRange,
                            dateFormatter: dateFormatter
                        )
                        
                        ActionButtonsView(
                            saveAction: saveExpense,
                            deleteAction: {
                                HapticManager.shared.trigger(.warning)
                                showDeleteConfirmation = true
                            },
                            saveButtonText: saveButtonText,
                            isEditMode: isEditMode,
                            isFormValid: isFormValid
                        )
                        .padding(.vertical, Constraint.largePadding)
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .showDeleteConfirmationAlert(
                    isPresented: $showDeleteConfirmation,
                    buttonAction: { deleteExpense()
                    },
                    secondaryButtonAction:  {
                        DispatchQueue.main.async {
                            showDeleteConfirmation = false
                        }
                    })
                .transition(.opacity)
            }
        }
        .onAppear(perform: loadExpenseData)
    }

    /// Date formatter for displaying the date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }

    /// Load data if editing an existing expense
    private func loadExpenseData() {
        if let expense = expenseToModify {
            expenseName = expense.name
            /// Format the amount to string
            expenseAmount = expense.amount
            expenseDate = expense.date
        }
        withAnimation(.smooth(duration: 1)){
            isVisible = true
        }
    }

    private func saveExpense() {
        /// Validate form
        guard isFormValid else {
            HapticManager.shared.trigger(.error)
            return
        }

        if let existingExpense = expenseToModify {
            /// Update existing expense
            existingExpense.updateProperties(
                name: expenseName.trimmingCharacters(in: .whitespacesAndNewlines),
                date: expenseDate,
                amount: expenseAmount
            )

            switch DataController.shared.updateExpense(of: existingExpense) {
            case .success:
                HapticManager.shared.trigger(.success)
                withAnimation {
                    appStateManager.hasUpdatedExpense = true
                }
            case let .failure(comingError):
                HapticManager.shared.trigger(.error)
                withAnimation {
                    appStateManager.error = comingError
                }
            }
        } else {
            /// Create a new expense
            let newExpense = ExpenseViewModel.create(
                id: UUID(),
                name: expenseName,
                date: expenseDate,
                amount: expenseAmount,
                createDate: .now
            )
            switch DataController.shared.saveExpense(of: newExpense) {
            case .success:
                HapticManager.shared.trigger(.add)
                withAnimation {
                    appStateManager.hasAddedExpense = true
                }
            case let .failure(comingError):
                HapticManager.shared.trigger(.error)
                withAnimation {
                    appStateManager.error = comingError
                }
            }
        }

        dismiss()
    }

    private func deleteExpense() {
        if let expense = expenseToModify {
            switch DataController.shared.deleteExpense(of: expense) {
            case .success:
                HapticManager.shared.trigger(.delete)
                withAnimation {
                    appStateManager.hasDeletedExpense = true
                }
            case let .failure(comingError):
                HapticManager.shared.trigger(.error)
                withAnimation {
                    appStateManager.error = comingError
                }
            }
            dismiss()
        }
    }
 
    private func dismiss() {
        switch isEditMode {
        case true:
            expenseToModify = .none
        case false:
            dismissView()
        }
    }
}

// MARK: - Background View
struct BackgroundView: View {
    var body: some View {
        /// Background color
        Color.customRichBlack.ignoresSafeArea()

        /// Semi-transparent overlay circle
        Circle()
            .fill(Color.customWhiteSand.opacity(Constraint.Opacity.low))
            .frame(width: UIScreen.main.bounds.width * 1.5)
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.45)
            .blur(radius: Constraint.blurRadius)
    }
}

// MARK: - Header View
struct HeaderView: View {
    /// Title based on mode
    let isEditMode: Bool

    var attributedTitle: AttributedString {
        switch isEditMode {
        case true:
            var attributedString = AttributedString(
                NSLocalizedString("modify_expense", comment: "")
            )
            
            if let helloRange = attributedString.range(of: NSLocalizedString("modify", comment: "")) {
                attributedString[helloRange].foregroundColor = .customWhiteSand.opacity(Constraint.Opacity.high)
                attributedString[helloRange].font = TextFonts.titleSmall.font
            }
            
            if let worldRange = attributedString.range(of: NSLocalizedString("expense", comment: "")) {
                attributedString[worldRange].foregroundColor = .customWhiteSand
                attributedString[worldRange].font = TextFonts.titleSmallBold.font
            }
            return attributedString

        case false:
            var attributedString = AttributedString(
                NSLocalizedString("add_expense", comment: "")
            )
            if let helloRange = attributedString.range(of: NSLocalizedString("add_capital", comment: "")) {
                attributedString[helloRange].foregroundColor = .customWhiteSand.opacity(Constraint.Opacity.high)
                attributedString[helloRange].font = TextFonts.titleSmall.font
            }
            
            if let worldRange = attributedString.range(of: NSLocalizedString("expense", comment: "")) {
                attributedString[worldRange].foregroundColor = .customWhiteSand
                attributedString[worldRange].font = TextFonts.titleSmallBold.font
            }
            return attributedString

        }
    }

    var body: some View {
        CustomNavigationBarTitleView(title: attributedTitle)
    }
}

// MARK: - Form Fields View
struct FormFieldsView: View {
    @Binding var expenseName: String
    @Binding var expenseAmount: Double
    @Binding var expenseDate: Date
    var dateRange: ClosedRange<Date>
    var dateFormatter: DateFormatter
    
    var body: some View {
        VStack(spacing: Constraint.largePadding) {
            /// Expense Name Field
            ExpenseNameFieldView(expenseName: $expenseName)
            
            /// Expense Amount Field
            ExpenseAmountFieldView(expenseAmount: $expenseAmount)
            
            /// Date Selector
            DateSelectorView(expenseDate: $expenseDate, dateRange: dateRange, dateFormatter: dateFormatter)
        }
        .padding(.horizontal, Constraint.padding)
    }
}

// MARK: - Expense Name Field View
struct ExpenseNameFieldView: View {
    @Binding var expenseName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constraint.smallPadding) {
            CustomTextView(
                NSLocalizedString("name", comment: ""),
                font: .labelLarge,
                color: .customWhiteSand
            )
            
            TextField("", text: $expenseName)
                .font(TextFonts.bodySmallBold.font)
                .foregroundColor(.white)
                .frame(height: 32)
                .addLayeredBackground(.customWhiteSand.opacity(Constraint.Opacity.medium))
                .onChange(of: expenseName) { _, _ in
                    HapticManager.shared.trigger(.selection)
                }
        }
    }
}

// MARK: - Expense Amount Field View
struct ExpenseAmountFieldView: View {
    @Binding var expenseAmount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constraint.smallPadding) {
            CustomTextView(
                NSLocalizedString("amount_capital", comment: ""),
                font: .labelLarge,
                color: .customWhiteSand
            )

            HStack {
                TextField("", value: $expenseAmount, format: .currency (code: "GBP"))
                    .keyboardType(.decimalPad)
                    .font(TextFonts.bodySmallBold.font)
                    .foregroundColor(.white)
                    .onChange(of: expenseAmount) { _, _ in
                        HapticManager.shared.trigger(.selection)
                    }
            }
            .frame(height: 32)
            .addLayeredBackground(.customWhiteSand.opacity(Constraint.Opacity.medium))
        }
    }
}

// MARK: - Date Selector View
struct DateSelectorView: View {
    @Binding var expenseDate: Date
    var dateRange: ClosedRange<Date>
    var dateFormatter: DateFormatter
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constraint.smallPadding) {
            CustomTextView(
                NSLocalizedString("date_capital", comment: ""),
                font: .labelLarge,
                color: .customWhiteSand
            )
            
            HStack {
                /// Date display
                DatePicker("", selection: $expenseDate, in: dateRange, displayedComponents: .date)
                    .font(TextFonts.bodySmallBold.font)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .preferredColorScheme(.dark)
                    .tint(.customRichBlack)
                    .onChange(of: expenseDate) { _, _ in
                        HapticManager.shared.trigger(.selection)
                    }

                Spacer()

                Image(systemName: "calendar")
                    .foregroundColor(.white)
                    .font(.system(size: Constraint.regularIconSize))
                    .padding(.trailing, Constraint.padding)
            }
            .frame(height: 32)
            .addLayeredBackground(.customWhiteSand.opacity(Constraint.Opacity.medium))
        }
    }
}

// MARK: - Action Buttons View
struct ActionButtonsView: View {
    var saveAction: () -> Void
    var deleteAction: () -> Void
    var saveButtonText: String
    var isEditMode: Bool
    var isFormValid: Bool

    var body: some View {
        VStack(spacing: Constraint.padding) {
            /// Save/Update Button
            Button(action: {
                if isFormValid {
                    HapticManager.shared.trigger(.buttonTap)
                    saveAction()
                } else {
                    HapticManager.shared.trigger(.error)
                }
            }) {
                CustomTextView(saveButtonText, font: .bodySmallBold, color: .customRichBlack.opacity(Constraint.Opacity.high))
                    .tracking(1)
                    .addLayeredBackground(
                        isFormValid ? .white : .white.opacity(Constraint.Opacity.medium),
                    )
            }
            .disabled(!isFormValid)

            /// Delete button (only in edit mode)
            if isEditMode {
                Button(action: deleteAction) {
                    CustomTextView(NSLocalizedString("delete_capital", comment: ""), font: .bodySmallBold, color: .customWhiteSand)
                        .tracking(1)
                        .addLayeredBackground(.customBurgundy)
                }
            }
        }
        .padding(.horizontal, Constraint.smallPadding)
        .padding(.bottom, Constraint.largePadding)
    }
}

// MARK: - Preview
#Preview("Add Mode") {
    ModifyExpenseView(expenseToModify: .constant(.none), startDay: .now)
}

#Preview("Edit Mode") {
    let sampleExpense = ExpenseViewModel.create(
        id: .init(),
        name: "Name",
        date: .now,
        amount: 22,
        createDate: .now
    )
    ModifyExpenseView(expenseToModify: .constant(sampleExpense), startDay: .now)
}
