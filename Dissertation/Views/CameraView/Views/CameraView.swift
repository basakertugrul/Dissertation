import SwiftUI
import PhotosUI

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    @StateObject var photosViewModel = PhotosPickerViewModel()

    @State private var isFocused = false
    @State private var isScaled = false
    @State private var focusLocation: CGPoint = .zero
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var showImagePreview = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Flash Button
                Button(action: {
                    viewModel.switchFlash()
                }) {
                    Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(viewModel.isFlashOn ? .yellow : .white)
                }
                
                // Camera Preview with Focus and Zoom
                ZStack {
                    CameraPreview(session: viewModel.session) { tapPoint in
                        isFocused = true
                        focusLocation = tapPoint
                        viewModel.setFocus(point: tapPoint)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                currentZoomFactor += value - 1.0
                                currentZoomFactor = min(max(currentZoomFactor, 0.5), 10)
                                viewModel.zoom(with: currentZoomFactor)
                            }
                    )
                    .animation(.easeInOut, value: 0.5)
                    
                    // Focus View
                    if isFocused {
                        FocusView(position: $focusLocation)
                            .scaleEffect(isScaled ? 0.8 : 1)
                            .onAppear {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    isScaled = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        isFocused = false
                                        isScaled = false
                                    }
                                }
                            }
                    }
                }
                
                // Bottom Controls
                HStack {
                    // Photo Library Access via Thumbnail
                    PhotosPicker(
                        selection: $photosViewModel.selectedPhotos,
                        maxSelectionCount: 1,
                        selectionBehavior: .ordered,
                        matching: .images
                    ) {
                        PhotoThumbnail()
                    }
                    
                    Spacer()
                    
                    // Capture Button
                    CaptureButton {
                        viewModel.captureImage()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showImagePreview = true
                        }
                    }
                    
                    Spacer()
                    
                    // Camera Switch Button
                    CameraSwitchButton {
                        viewModel.switchCamera()
                    }
                }
                .padding(Constraint.padding)
            }
            .padding(Constraint.padding)
            
            // Full-screen Image Preview Overlay (for both captured and selected photos)
            if showImagePreview, let image = viewModel.capturedImage {
                ImagePreviewOverlay(
                    image: image,
                    isVisible: $showImagePreview,
                    viewModel: viewModel
                )
                .preferredColorScheme(.dark)
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .showPhotoLibraryErrorAlert(isPresented: $viewModel.showPhotoErrorAlert) {
            viewModel.showPhotoErrorAlert = false
        }
        .showCameraErrorAlert(isPresented: $viewModel.showCameraErrorAlert) {
            viewModel.showCameraErrorAlert = false
        }
        .showSettingsErrorAlert(isPresented: $viewModel.showSettingAlert) {
            openSettings()
        }
        .onAppear {
            viewModel.setupBindings()
            viewModel.requestCameraPermission()
        }
        .onChange(of: photosViewModel.selectedPhotos) { _, newValue in
            handlePhotoSelection()
        }
    }

    private func handlePhotoSelection() {
        guard let selectedPhoto = photosViewModel.selectedPhotos.first else { return }
        
        Task {
            if let imageData = try? await selectedPhoto.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    // Set the selected image as captured image and show preview
                    self.viewModel.capturedImage = uiImage
                    self.showImagePreview = true
                    
                    // Clear the selection for next time
                    self.photosViewModel.selectedPhotos.removeAll()
                }
            }
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Supporting Views

struct CaptureButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 59, height: 59)
                )
        }
    }
}

struct CameraSwitchButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white)
                )
        }
    }
}

struct FocusView: View {
    @Binding var position: CGPoint

    var body: some View {
        Circle()
            .frame(width: 72, height: 72)
            .foregroundColor(.clear)
            .border(Color.yellow, width: 1.5)
            .position(x: position.x, y: position.y)
    }
}
