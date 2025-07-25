import SwiftUI
import PhotosUI
import AVFoundation

// MARK: - Camera View
struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) private var dismiss
    
    // UI State
    @State private var isFocused = false
    @State private var isScaled = false
    @State private var focusLocation: CGPoint = .zero
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var showImagePreview = false
    @State private var isImageFromGallery = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.customRichBlack.ignoresSafeArea()
                cameraInterface
                
                // Image Preview Overlay
                if showImagePreview {
                    ImagePreview(
                        cameraManager: cameraManager,
                        isFromGallery: isImageFromGallery,
                        onSave: handleImageSave,
                        onRetake: handleRetake,
                        onDismiss: { showImagePreview = false }
                    )
                    .transition(.opacity)
                }
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
        .onAppear {
            cameraManager.checkForDevicePermission()
        }
        .onChange(of: cameraManager.capturedImage) { _, newImage in
            if newImage != nil {
                showImagePreview = true
            }
        }
        .onChange(of: $cameraManager.selectedPhotos.wrappedValue) { _, _ in
            handlePhotoSelection()
        }
        .showCameraErrorAlert(isPresented: $cameraManager.showCameraErrorAlert) {
            cameraManager.showCameraErrorAlert = false
        }
        .showPhotoLibraryErrorAlert(isPresented: $cameraManager.showPhotoErrorAlert) {
            cameraManager.showPhotoErrorAlert = false
        }
        .showCameraErrorAlert(isPresented: $cameraManager.showCameraErrorAlert) {
            cameraManager.showCameraErrorAlert = false
        }
        .showSettingsErrorAlert(isPresented: $cameraManager.showSettingAlert) {
            openSettings()
        }
    }
    
    // MARK: - Camera Interface
    private var cameraInterface: some View {
        VStack(spacing: .zero) {
            headerSection
            topControls
            Spacer()
            cameraPreviewSection
            Spacer()
            bottomControls
        }
        .padding(.vertical, Constraint.padding)
    }
    
    // MARK: - Header
    private var headerSection: some View {
        var attributedTitle: AttributedString {
            var attributedString = AttributedString(NSLocalizedString("scan_entry", comment: ""))
            
            if let helloRange = attributedString.range(of: NSLocalizedString("scan", comment: "")) {
                attributedString[helloRange].foregroundColor = .customWhiteSand.opacity(Constraint.Opacity.high)
                attributedString[helloRange].font = TextFonts.titleSmall.font
            }
            if let worldRange = attributedString.range(of: NSLocalizedString("entry", comment: "")) {
                attributedString[worldRange].foregroundColor = .customWhiteSand
                attributedString[worldRange].font = TextFonts.titleSmallBold.font
            }
            return attributedString
        }
        return CustomNavigationBarTitleView(title: attributedTitle)
    }

    // MARK: - Top Controls
    private var topControls: some View {
        // Flash Button
        Button(action: toggleFlash) {
            Image(systemName: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(cameraManager.isFlashOn ? .yellow : .white)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
        }
    }
    
    // MARK: - Camera Preview Section
    private var cameraPreviewSection: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera Preview
                CameraPreview(session: cameraManager.session) { tapPoint in
                    let convertedPoint = CGPoint(
                        x: tapPoint.x * geometry.size.width,
                        y: tapPoint.y * geometry.size.height
                    )
                    handleFocusTap(at: convertedPoint)
                }
                .clipShape(RoundedRectangle(cornerRadius: Constraint.cornerRadius))
                .gesture(zoomGesture)

                // Focus Indicator
                if isFocused {
                    FocusView(position: $focusLocation)
                        .scaleEffect(isScaled ? 0.8 : 1)
                        .onAppear {
                            animateFocus()
                        }
                }

                // Zoom Indicator
                if currentZoomFactor > 1.1 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(currentZoomFactor, specifier: "%.1f")x")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        HStack(spacing: 0) {
            // Photo Library Button
            PhotosPicker(
                selection: $cameraManager.selectedPhotos,
                maxSelectionCount: 1,
                selectionBehavior: .ordered,
                matching: .images
            ) {
                PhotoThumbnail()
                    .frame(width: 50, height: 50)
            }
            .onTapGesture {
                HapticManager.shared.trigger(.buttonTap)
            }
            
            Spacer()
            
            // Capture Button
            CaptureButton {
                capturePhoto()
            }
            .disabled(cameraManager.status != .configured)
            
            Spacer()
            
            // Camera Switch Button
            CameraSwitchButton {
                switchCamera()
            }
            .frame(width: 50, height: 50)
        }
        .padding(.horizontal, 30)
    }
    
    struct PhotoThumbnail: View {
        var body: some View {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: "photo.stack")
                        .foregroundColor(.white)
                )
        }
    }
    
    // MARK: - Gestures
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / currentZoomFactor
                currentZoomFactor *= delta
                currentZoomFactor = max(1.0, min(currentZoomFactor, 10.0))
                cameraManager.zoom(with: currentZoomFactor)
                
                // Haptic feedback for zoom changes
                if abs(delta - 1.0) > 0.1 {
                    HapticManager.shared.trigger(.light)
                }
            }
    }
    
    // MARK: - Actions
    private func toggleFlash() {
        cameraManager.switchFlash()
        HapticManager.shared.trigger(.buttonTap)
    }
    
    private func handleFocusTap(at point: CGPoint) {
        isFocused = true
        focusLocation = point
        cameraManager.setFocus(point: point)
        HapticManager.shared.trigger(.selection)
    }
    
    private func animateFocus() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isScaled = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.2)) {
                isFocused = false
                isScaled = false
            }
        }
    }
    
    private func capturePhoto() {
        cameraManager.captureImage()
        isImageFromGallery = false
        HapticManager.shared.trigger(.heavy)
    }
    
    private func switchCamera() {
        cameraManager.switchCamera()
        HapticManager.shared.trigger(.medium)
    }
    
    private func handlePhotoSelection() {
        guard let selectedPhoto = $cameraManager.selectedPhotos.first?.wrappedValue else { return }
        
        Task {
            do {
                if let imageData = try await selectedPhoto.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: imageData) {
                    await MainActor.run {
                        cameraManager.capturedImage = uiImage
                        isImageFromGallery = true
                        cameraManager.selectedPhotos.removeAll()
                        HapticManager.shared.trigger(.success)
                    }
                }
            } catch {
                HapticManager.shared.trigger(.error)
            }
        }
    }
    
    private func handleImageSave(_ image: UIImage) {
        cameraManager.saveImageToGallery(image: image)
        HapticManager.shared.trigger(.success)
    }
    
    private func handleRetake() {
        cameraManager.capturedImage = nil
        isImageFromGallery = false
        showImagePreview = false
        HapticManager.shared.trigger(.medium)
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
            HapticManager.shared.trigger(.navigation)
        }
    }
}

// MARK: - Supporting Views

struct CaptureButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .stroke(Color.black.opacity(0.2), lineWidth: 3)
                    .frame(width: 70, height: 70)
            }
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: UUID())
    }
}

struct CameraSwitchButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "camera.rotate.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.black.opacity(0.3))
                .clipShape(Circle())
        }
    }
}

struct FocusView: View {
    @Binding var position: CGPoint
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.yellow, lineWidth: 2)
            .frame(width: 80, height: 80)
            .position(position)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onTapGesture {
                HapticManager.shared.trigger(.buttonTap)
            }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onTapGesture {
                HapticManager.shared.trigger(.light)
            }
    }
}
