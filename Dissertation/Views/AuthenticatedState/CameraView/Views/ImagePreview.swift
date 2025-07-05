import SwiftUI
import PhotosUI

// MARK: - Image Preview
struct ImagePreview: View {
    @EnvironmentObject var appState: AppStateManager
    @ObservedObject var cameraManager: CameraManager
    let isFromGallery: Bool
    let onSave: (UIImage) -> Void
    let onRetake: () -> Void
    let onDismiss: () -> Void
    
    @State private var isSaved = false
    @State private var currentImageHash: Int? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var receiptData: ReceiptData?
    
    var body: some View {
        VStack {
            if let image = cameraManager.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack(spacing: 40) {
                // Retake Button
                Button(action: {
                    HapticManager.shared.trigger(.cancel)
                    onRetake()
                }) {
                    CustomTextView(NSLocalizedString("retake", comment: ""), font: .bodySmallBold)
                        .foregroundColor(.white)
                }
                .frame(width: 120, height: 50)
                .background(
                    ZStack {
                        // Burgundy glass effect
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.5, green: 0.1, blue: 0.2).opacity(0.8),
                                                Color(red: 0.3, green: 0.05, blue: 0.1).opacity(0.9)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    }
                )
                
                // Add Button
                Button(action: {
                    HapticManager.shared.trigger(.add)
                    if let image = cameraManager.capturedImage {
                        withAnimation {
                            isLoading = true
                        }
                        
                        if !isSaved {
                            onSave(image)
                            isSaved = true
                        }
                        let recognizer = ReceiptTextRecognizer(startDate: appState.startDate)
                        DispatchQueue.global(qos: .background).async {
                            recognizer.recognizeReceiptData(from: image) { result in
                                switch result {
                                case let .success(data):
                                    DispatchQueue.main.async {
                                        HapticManager.shared.trigger(.success)
                                        withAnimation {
                                            isLoading = false
                                            errorMessage = nil
                                            receiptData = data
                                        }
                                    }
                                case let .failure(error):
                                    DispatchQueue.main.async {
                                        HapticManager.shared.trigger(.error)
                                        withAnimation {
                                            isLoading = false
                                            receiptData = nil
                                            errorMessage = error.description
                                        }
                                    }
                                }
                            }
                        }
                    }
                }) {
                    CustomTextView(NSLocalizedString("add", comment: ""), font: .bodySmallBold)
                }
                .frame(width: 120, height: 50)
                .background(
                    ZStack {
                        // Green glass effect
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.1, green: 0.6, blue: 0.3).opacity(0.8),
                                                Color(red: 0.05, green: 0.4, blue: 0.2).opacity(0.9)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    }
                )
            }
            .padding(.bottom, Constraint.extremePadding)
        }
        .background(Color.black.ignoresSafeArea())
        .loadingOverlay($isLoading)
        .showNoReceiptFoundErrorAlert(isPresented: .init(get: {
            errorMessage != nil
        }, set: { bool in
            if !bool {
                receiptData = nil
                errorMessage = nil
            }
        }),
            message: errorMessage ?? "",
        ) {
            DispatchQueue.main.async {
                withAnimation {
                    errorMessage = nil
                    receiptData = nil
                }
            }
        }
        .showReceiptFoundAlert(
            isPresented: .init(get: {
                receiptData != nil
            }, set: { bool in
                if !bool {
                    receiptData = nil
                    errorMessage = nil
                }
            }),
            receiptData: receiptData ?? ReceiptData(totalAmount: .zero),
            onTap: saveTheReceipt
        )
        .onAppear {
            // Set initial state based on gallery source
            isSaved = isFromGallery
            currentImageHash = cameraManager.capturedImage?.hashValue
        }
        .onChange(of: cameraManager.capturedImage) { _, newImage in
            // Only reset if this is actually a new/different image
            let newHash = newImage?.hashValue
            if newHash != currentImageHash {
                currentImageHash = newHash
                isSaved = isFromGallery
            }
        }
    }
    
    func saveTheReceipt(of receipt: ReceiptData?) {
        HapticManager.shared.trigger(.success)
        DispatchQueue.main.async {
            withAnimation {
                appState.willOpenCameraView = false
            }
        }

        guard let receipt = receipt else { return }
        let newExpense: ExpenseViewModel = .create(
            id: UUID(),
            name: receipt.merchantName ?? "",
            date: receipt.date ?? .now,
            amount: receipt.totalAmount ?? .zero,
            createDate: .now
        )
        switch DataController.shared.saveExpense(of: newExpense) {
        case .success:
            HapticManager.shared.trigger(.add)
            withAnimation {
                appState.hasAddedExpense = true
            }
        case let .failure(comingError):
            HapticManager.shared.trigger(.error)
            withAnimation {
                appState.error = comingError
            }
        }
    }
}
