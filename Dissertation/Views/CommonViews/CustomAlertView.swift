import SwiftUI

// MARK: - The Custom Alert View
struct CustomAlertView: View {
    // Required properties
    @Binding var isShowing: Bool
    let title: String
    let message: String
    let buttonText: String
    let buttonAction: () -> Void
    let secondaryButtonText: String?
    let secondaryButtonAction: (() -> Void)?
    let alertColor: Color
    let isMessageBold: Bool
    
    init(
        isShowing: Binding<Bool>,
        title: String,
        message: String,
        buttonText: String,
        buttonAction: @escaping () -> Void,
        secondaryButtonText: String?,
        secondaryButtonAction: (() -> Void)?,
        alertColor: Color,
        isMessageBold: Bool = false
    ) {
        self._isShowing = isShowing
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.buttonAction = buttonAction
        self.secondaryButtonText = secondaryButtonText
        self.secondaryButtonAction = secondaryButtonAction
        self.alertColor = alertColor
        self.isMessageBold = isMessageBold
    }
    
    var body: some View {
        /// Alert container
        ZStack {
            /// Dimmed background
            Color.customRichBlack
                .opacity(Constraint.Opacity.medium)
                .ignoresSafeArea()
                .onTapGesture { if let secondaryButtonAction = secondaryButtonAction { secondaryButtonAction() } }

            VStack(spacing: .zero) {
                /// Alert header
                VStack(spacing: Constraint.padding) {
                    CustomTextView(
                        title,
                        font: .bodySmallBold,
                        color: .white
                    )
                    
                    CustomTextView(
                        message,
                        font: isMessageBold ? .labelLargeBold : .labelLarge
                    )
                    .multilineTextAlignment(.center)
                }
                .frame(width: Constraint.largeImageSize)
                .padding(Constraint.largePadding)
                .background(alertColor)

                /// Buttons
                HStack(spacing: .zero) {
                    if let secondaryText = secondaryButtonText, let secondaryAction = secondaryButtonAction {
                        /// Two buttons layout
                        Button(action: {
                            secondaryAction()
                            isShowing = false
                        }) {
                            CustomTextView(
                                secondaryText,
                                font: .bodySmall,
                                color: Color.customRichBlack.opacity(Constraint.Opacity.medium)
                            )
                        }
                        .frame(width: Constraint.largeImageSize/2, alignment: .center)

                        Divider()
                            .background(Color.customRichBlack.opacity(Constraint.Opacity.low))
                    }
                    Button(action: {
                        buttonAction()
                        isShowing = false
                    }) {
                        CustomTextView(
                            buttonText,
                            font: .bodySmallBold,
                            color: alertColor
                        )
                    }
                    .frame(width: Constraint.largeImageSize/2 - 1, alignment: .center)
                }
                .frame(height: Constraint.extremeIconSize)
            }
            .padding(.horizontal, Constraint.largePadding)
            .frame(width: Constraint.largeImageSize)
            .background(
                Color.white
                    .shadow(radius: Constraint.shadowRadius)
            )
            .clipShape(RoundedRectangle(cornerRadius: Constraint.cornerRadius))
            .zIndex(10)
        }
    }
}
