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
                    title: "Delete Expense",
                    message: "Are you sure you want to delete this expense?",
                    buttonText: "Delete",
                    buttonAction: buttonAction,
                    secondaryButtonText: "Cancel",
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
                    title: "Sign Out",
                    message: "Are you sure you want to sign out of FundBud?",
                    buttonText: "Sign Out",
                    buttonAction: buttonAction,
                    secondaryButtonText: "Cancel",
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
                    title: "Camera Error",
                    message: "Permissions are required.",
                    buttonText: "OK",
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
                    title: "Photo Library Error",
                    message: "Permissions are required.",
                    buttonText: "OK",
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
                    title: "Permissions Required",
                    message: "Camera and photo access needed to capture and store receipt photos.",
                    buttonText: "Go to settings",
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
    func showAddedExpenseAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
                .zIndex(0)
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: "Added Expense",
                    message: "Great! Keep monitoring your budget!",
                    buttonText: "OK",
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
                    title: "Deleted Expense",
                    message: "The expense has been removed.",
                    buttonText: "OK",
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
    func showModifiedExpenseAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                CustomAlertView(
                    isShowing: isPresented,
                    title: "Modified Expense",
                    message: "Your changes have been saved successfully.",
                    buttonText: "OK",
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
                    title: "Daily Limit Updated",
                    message: "Your new spending limit is now active.",
                    buttonText: "OK",
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
                    title: "Error",
                    message: errorMessage,
                    buttonText: "OK",
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
                    title: "Rate FundBud",
                    message: "Would you like to rate our app in AppStore?",
                    buttonText: "OK",
                    buttonAction: onTap,
                    secondaryButtonText: "Cancel",
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
                    title: "Send Feedback",
                    message: "This will open your mail app to send feedback to our team.",
                    buttonText: "OK",
                    buttonAction: onTap,
                    secondaryButtonText: "Cancel",
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
                    title: "Export Data",
                    message: "This will export all your expense data as a PDF file.",
                    buttonText: "OK",
                    buttonAction: onTap,
                    secondaryButtonText: "Cancel",
                    secondaryButtonAction: { isPresented.wrappedValue = false },
                    alertColor: .customOliveGreen
                )
                .animation(.smooth, value: isPresented.wrappedValue)
            }
        }
    }
}
 /// For report: the request ones are for to be used later the release
