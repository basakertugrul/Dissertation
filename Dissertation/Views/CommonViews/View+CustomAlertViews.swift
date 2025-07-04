import SwiftUI

extension View {
    /// Show Delete Confirm Alert
    func showDeleteConfirmationAlert(
        isPresented: Binding<Bool>,
        buttonAction: @escaping () -> Void,
        secondaryButtonAction: @escaping () -> Void
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("delete_expense_title", comment: ""),
                    message: NSLocalizedString("delete_expense_message", comment: ""),
                    buttonText: NSLocalizedString("delete", comment: ""),
                    buttonAction: buttonAction,
                    secondaryButtonText: NSLocalizedString("cancel", comment: ""),
                    secondaryButtonAction: secondaryButtonAction,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show Logout Confirm Alert
    func showLogOutConfirmationAlert(
        isPresented: Binding<Bool>,
        buttonAction: @escaping () -> Void,
        secondaryButtonAction: @escaping () -> Void
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("sign_out_title", comment: ""),
                    message: NSLocalizedString("sign_out_message", comment: ""),
                    buttonText: NSLocalizedString("sign_out", comment: ""),
                    buttonAction: buttonAction,
                    secondaryButtonText: NSLocalizedString("cancel", comment: ""),
                    secondaryButtonAction: secondaryButtonAction,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }


    /// Show Camera Error Alert
    func showCameraErrorAlert(
        isPresented: Binding<Bool>,
        buttonAction: @escaping () -> Void = {},
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("camera_error_title", comment: ""),
                    message: NSLocalizedString("permissions_required_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: buttonAction,
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
    
    /// Show Photo Library Error Alert
    func showPhotoLibraryErrorAlert(
        isPresented: Binding<Bool>,
        buttonAction: @escaping () -> Void = {},
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("photo_library_error_title", comment: ""),
                    message: NSLocalizedString("permissions_required_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: buttonAction,
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show Photo Library Error Alert
    func showSettingsErrorAlert(
        isPresented: Binding<Bool>,
        buttonAction: @escaping () -> Void = {},
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("permissions_required_title", comment: ""),
                    message: NSLocalizedString("camera_photo_permissions_message", comment: ""),
                    buttonText: NSLocalizedString("go_to_settings", comment: ""),
                    buttonAction: buttonAction,
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show Voice Error Alert
    func showVoiceErrorAlert(
        isPresented: Binding<Bool>,
        buttonAction: @escaping () -> Void = {},
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("permissions_required_title", comment: ""),
                    message: NSLocalizedString("microphone_permissions_message", comment: ""),
                    buttonText: NSLocalizedString("go_to_settings", comment: ""),
                    buttonAction: buttonAction,
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show Voice General Error Alert
    func showVoiceGeneralErrorAlert(
        isPresented: Binding<Bool>,
        buttonAction: @escaping () -> Void = {},
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("recording_error_title", comment: ""),
                    message: NSLocalizedString("recording_error_message", comment: ""),
                    buttonText: NSLocalizedString("try_again", comment: ""),
                    buttonAction: buttonAction,
                    secondaryButtonText: NSLocalizedString("cancel", comment: ""),
                    secondaryButtonAction: {
                        isPresented.wrappedValue = false
                    },
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show Photo Library Error Alert
    func showAddedExpenseAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
                .zIndex(0)
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("added_expense_title", comment: ""),
                    message: NSLocalizedString("added_expense_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: { isPresented.wrappedValue = false },
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customOliveGreen
                )
                .zIndex(1)
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show Deleted Expense Alert
    func showDeletedExpenseAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("deleted_expense_title", comment: ""),
                    message: NSLocalizedString("deleted_expense_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: { isPresented.wrappedValue = false },
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
    
    /// Show Modified Expense Alert
    func showModifiedExpenseAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("modified_expense_title", comment: ""),
                    message: NSLocalizedString("modified_expense_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: { isPresented.wrappedValue = false },
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customOliveGreen
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show Modified Expense Alert
    func showSavedDailyLimitAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("daily_limit_updated_title", comment: ""),
                    message: NSLocalizedString("daily_limit_updated_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: { isPresented.wrappedValue = false },
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customOliveGreen
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
    
    /// Show Error Alert
    func showErrorAlert(
        isPresented: Binding<Bool>,
        errorMessage: String,
        onTap: @escaping (() -> Void)
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("error", comment: ""),
                    message: errorMessage,
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: onTap,
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show App Rate Confirmation Alert
    func showAppRateConfirmationAlert(
        isPresented: Binding<Bool>,
        onTap: @escaping (() -> Void)
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("rate_fundbud_title", comment: ""),
                    message: NSLocalizedString("rate_fundbud_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: onTap,
                    secondaryButtonText: NSLocalizedString("cancel", comment: ""),
                    secondaryButtonAction: { isPresented.wrappedValue = false },
                    alertColor: .customOliveGreen
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show App Rate Confirmation Alert
    func showSendFeedbackConfirmationAlert(
        isPresented: Binding<Bool>,
        onTap: @escaping (() -> Void)
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("send_feedback_title", comment: ""),
                    message: NSLocalizedString("send_feedback_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: onTap,
                    secondaryButtonText: NSLocalizedString("cancel", comment: ""),
                    secondaryButtonAction: { isPresented.wrappedValue = false },
                    alertColor: .customOliveGreen
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show App Rate Confirmation Alert
    func showExportDataConfirmationAlert(
        isPresented: Binding<Bool>,
        onTap: @escaping (() -> Void)
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("export_data_title", comment: ""),
                    message: NSLocalizedString("export_data_message", comment: ""),
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: onTap,
                    secondaryButtonText: NSLocalizedString("cancel", comment: ""),
                    secondaryButtonAction: { isPresented.wrappedValue = false },
                    alertColor: .customOliveGreen
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show App Rate Confirmation Alert
    func showNoReceiptFoundErrorAlert(
        isPresented: Binding<Bool>,
        message: String,
        onTap: @escaping (() -> Void)
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("no_receipt_detected_title", comment: ""),
                    message: message,
                    buttonText: NSLocalizedString("ok", comment: ""),
                    buttonAction: {
                        isPresented.wrappedValue = false
                        onTap()
                    },
                    secondaryButtonText: .none,
                    secondaryButtonAction: .none,
                    alertColor: .customBurgundy
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }

    /// Show App Rate Confirmation Alert
    func showReceiptFoundAlert(
        isPresented: Binding<Bool>,
        receiptData: ReceiptData,
        onTap: @escaping (ReceiptData?) -> Void
    ) -> some View {
        var formattedCurrentDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: .now)
        }
        let name: String = receiptData.merchantName ?? ""
        let amount: String = receiptData.formattedAmount ?? ""
        let date: String = receiptData.formattedDate ?? formattedCurrentDate

        return ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: NSLocalizedString("receipt_detected_title", comment: ""),
                    // TODO: amount formatting
                    message: "\(name)\n\(amount)\n\(date)",
                    buttonText: NSLocalizedString("add_to_expenses", comment: ""),
                    buttonAction: {
                        isPresented.wrappedValue = false
                        onTap(receiptData)
                    },
                    secondaryButtonText: NSLocalizedString("cancel", comment: ""),
                    secondaryButtonAction: { isPresented.wrappedValue = false },
                    alertColor: .customOliveGreen,
                    isMessageBold: true
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
}
 /// For report: the request ones are for to be used later the release
