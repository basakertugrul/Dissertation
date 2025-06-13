import SwiftUI

extension View {
    /// Show Delete Confirm Alert
    func showDeleteConfirmationAlert(
        isPresented: Binding<Bool>,
        buttonAction: @escaping () -> Void = {},
        secondaryButtonAction: @escaping () -> Void = {}
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
    ) -> some View { // TODO: Add this to required places
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
}
 /// For report: these two to be used later the release
