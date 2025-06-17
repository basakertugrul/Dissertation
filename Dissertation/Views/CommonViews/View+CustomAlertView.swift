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
            }
        }
        .animation(.smooth(duration: Constraint.animationDurationShort))
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
                    message: "Are you sure you want to sign out of BudgetMate?",
                    buttonText: "Sign Out",
                    buttonAction: buttonAction,
                    secondaryButtonText: "Cancel",
                    secondaryButtonAction: secondaryButtonAction,
                    alertColor: .customBurgundy
                )
            }
        }
        .animation(.smooth(duration: Constraint.animationDurationShort))
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
            }
        }
        .animation(.smooth(duration: Constraint.animationDurationShort))
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
            }
        }
        .animation(.smooth(duration: Constraint.animationDurationShort))
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
            }
        }
        .animation(.smooth(duration: Constraint.animationDurationShort))
    }

    /// Show Photo Library Error Alert
    func showAddedExpenseAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        ZStack {
            self
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
            }
        }
    }
}
 /// For report: the request ones are for to be used later the release
