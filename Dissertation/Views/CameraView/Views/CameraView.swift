import SwiftUI

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    @State private var isFocused = false
    @State private var isScaled = false
    @State private var focusLocation: CGPoint = .zero
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var showImagePreview = false
    @State private var showPhotoPicker: Bool = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Button(action: {
                    viewModel.switchFlash()
                }, label: {
                    Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 20, weight: .medium, design: .default))
                })
                .accentColor(viewModel.isFlashOn ? .yellow : .white)

                ZStack {
                    CameraPreview(session: viewModel.session) { tapPoint in
                        isFocused = true
                        focusLocation = tapPoint
                        viewModel.setFocus(point: tapPoint)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            self.currentZoomFactor += value - 1.0 /// Calculate the zoom factor change
                            self.currentZoomFactor = min(max(self.currentZoomFactor, 0.5), 10)
                            self.viewModel.zoom(with: currentZoomFactor)
                        })
                    .animation(.easeInOut, value: 0.5)
                    
                    if isFocused {
                        FocusView(position: $focusLocation)
                            .scaleEffect(isScaled ? 0.8 : 1)
                            .onAppear {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                                    self.isScaled = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        self.isFocused = false
                                        self.isScaled = false
                                    }
                                }
                            }
                    }
                }
                HStack {
                    // Modified PhotoThumbnail with tap action
                    PhotoThumbnail(image: $viewModel.capturedImage)
                        .onTapGesture {
                            if viewModel.capturedImage != .none {
                                showImagePreview = true
                            } else {
                                showPhotoPicker = true
                            }
                        }
                        .onLongPressGesture {
                            showPhotoPicker = true
                        }
                    Spacer()
                    CaptureButton {
                        viewModel.captureImage()
                        // Show the preview after a short delay to ensure the image is processed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showImagePreview = true
                        }
                    }
                    Spacer()
                    CameraSwitchButton { viewModel.switchCamera() }
                }
                .padding(Constraint.padding)
            }
            .padding(Constraint.padding)

            /// Full-screen image preview overlay
            if showImagePreview, let image = viewModel.capturedImage {
                ImagePreviewOverlay(image: image, isVisible: $showImagePreview, viewModel: viewModel)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            NavigationView {
                PhotosPickerView { image in
                    viewModel.capturedImage = image
                    showPhotoPicker = false
                }
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showPhotoPicker = false
                    }
                )
            }
        }
        .showPhotoLibraryErrorAlert(isPresented: $viewModel.showPhotoErrorAlert) {
            DispatchQueue.main.async {
                viewModel.showPhotoErrorAlert = false
            }
        }
        .showCameraErrorAlert(isPresented: $viewModel.showCameraErrorAlert) {
            DispatchQueue.main.async {
                viewModel.showCameraErrorAlert = false
            }
        }
        .showSettingsErrorAlert(isPresented: $viewModel.showSettingAlert) {
            DispatchQueue.main.async {
                self.openSettings()
            }
        }
        .onAppear {
            viewModel.setupBindings()
            viewModel.requestCameraPermission()
        }
    }

    func openSettings() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

struct CaptureButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundColor(.white)
                .frame(width: 70, height: 70, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 59, height: 59, alignment: .center)
                )
        }
    }
}

struct CameraSwitchButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        }
    }
}

struct FocusView: View {
    @Binding var position: CGPoint

    var body: some View {
        Circle()
            .frame(width: 70, height: 70)
            .foregroundColor(.clear)
            .border(Color.yellow, width: 1.5)
            .position(x: position.x, y: position.y)
    }
}
