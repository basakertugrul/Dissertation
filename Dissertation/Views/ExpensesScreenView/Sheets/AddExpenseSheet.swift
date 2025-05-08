import SwiftUI

struct AddExpenseSheet: View { // TODO: Do the updateExpenseSheet like this too
    @Environment(\.presentationMode) private var presentationMode
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var amount: Double = 0

    var dateRange: ClosedRange<Date> {
        let now: Date = Date()
        let distantPast: Date = .distantPast
        return distantPast...now
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with buttons
            navBarView

            // Form Content
            ScrollView {
                VStack(spacing: 16) {
                    // Form header
                    formHeaderView
                    
                    // Simple form fields
                    VStack(spacing: 16) {
                        // Name Field
                        TextField("Name", text: $name)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(8)

                        // Amount Field
                        TextField("Amount", value: $amount, format: .currency(code: "GBP"))
                            .keyboardType(.decimalPad)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(8)

                        // Date Field
                        DatePicker("Date", selection: $date, in: dateRange, displayedComponents: .date)
                            .tint(.burgundy)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 80)
                }
                .padding(.top, 16)
            }
            .background(Color.whiteSand.opacity(0.1))
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
        }
        .customBackground(with: .burgundy)
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Navigation Bar View
    private var navBarView: some View {
        HStack {
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.system(size: 16))
            .foregroundColor(Color.whiteSand)
            
            Spacer()
            
            Text("New Expense")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.whiteSand)
            
            Spacer()
            
            Button("Save") {
                saveExpense()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color.white)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
    }

    // MARK: - Form Header View
    private var formHeaderView: some View {
        HStack {
            Text("EXPENSE DETAILS")
                .font(.system(size: 12, weight: .medium))
                .tracking(1.5)
                .foregroundColor(Color.whiteSand.opacity(0.5))
                .padding(.bottom, 16)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Save Function
    private func saveExpense() {
        if amount > 0 {
            let newExpense = ExpenseViewModel.createWithPound(
                name: name,
                date: date,
                amount: amount,
                createDate: .now
            )
            DataController.shared.saveExpense(of: newExpense)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
