import SwiftUI
import PhotosUI

// MARK: - Image Preview
struct ImagePreview: View {
    @ObservedObject var cameraManager: CameraManager
    let isFromGallery: Bool
    let onSave: (UIImage) -> Void
    let onRetake: () -> Void
    let onDismiss: () -> Void
    
    @State private var isSaved = false
    @State private var currentImageHash: Int? = nil
    @State private var isLoading: Bool = false
    
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
                    onRetake()
                }) {
                    CustomTextView("Retake", font: .bodySmallBold)
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
                    if let image = cameraManager.capturedImage {
                        withAnimation {
                            print("isloading is true")
                            isLoading = true
                        }
                        
                        if !isSaved {
                            onSave(image)
                            isSaved = true // Mark as saved
                        }
                        let recognizer = ReceiptTextRecognizer()
                        DispatchQueue.global(qos: .background).async {
                            recognizer.recognizeReceiptData(from: image) { result in
                                switch result {
                                case let .success(data):
                                    print("Receipt data: \(data)")
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            isLoading = false
                                        }
                                    }
                                case let .failure(error):
                                    print("Error recognizing receipt: \(error)")
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            isLoading = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }) {
                    CustomTextView("Add", font: .bodySmallBold)
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
}
