import SwiftUI

struct TargetSpendingView: View {
    @Binding var openGoalMoneySpentScreen: Bool
    @State var targetSpending: Double?

    var onDissmiss: (Double) -> Void

    var body: some View {
        if openGoalMoneySpentScreen {
            VStack(spacing: 16) {
                ZStack {
                    Text("Set Daily Limit")
                        .font(.title)
                        .foregroundStyle(.customGray)
                        .shadow(color: .customGray.opacity(0.2), radius: 2)

                    Button(action: {
                        DispatchQueue.main.async {
                            openGoalMoneySpentScreen = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.customGray)
                            .frame(width: 32, height: 32)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 16)

                TextField("", value: $targetSpending, format: .currency (code: "GBP"))
                    .keyboardType(.decimalPad)
                    .tint(.customGray)
                    .foregroundStyle(.customGray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(width: UIScreen.main.bounds.width/3)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundStyle(.customLight)
                            .shadow(color: .gray.opacity(0.2), radius: 2)
                    )

                Button {
                    if let targetSpending = targetSpending {
                        onDissmiss(targetSpending)
                    }
                } label: {
                    Text("Set")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .shadow(color: .customGray.opacity(0.2), radius: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundStyle(.customDarkBlue)
                                .shadow(color: .customGray.opacity(0.2), radius: 2)
                        )
                }

            }
            .transition(.opacity)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(Color.customGreen)
                    .shadow(color: .customGray, radius: 2)
                    .padding(.horizontal, 48)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Rectangle()
                    .foregroundStyle(Color(UIColor.separator))
                    .onTapGesture {
                        DispatchQueue.main.async {
                            openGoalMoneySpentScreen = false
                        }
                    }
            )
        }
    }
}
