import Photos
import SwiftUI
import AVFoundation

enum Status {
    case configured
    case unconfigured
    case unauthorized
    case failed
}

class CameraManager: ObservableObject {
    @Published var capturedImage: UIImage? = .none
    @Published private var flashMode: AVCaptureDevice.FlashMode = .off
    
    @Published var status = Status.unconfigured
    @Published var showCameraErrorAlert = false
    @Published var showPhotoErrorAlert = false
    
    let session = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var videoDeviceInput: AVCaptureDeviceInput?
    var position: AVCaptureDevice.Position = .back
    
    private var cameraDelegate: CameraDelegate?

    /// Communicate with the session and other session objects with this queue.
    private let sessionQueue = DispatchQueue(label: "com.BudgetMate.sessionQueue")

    func configureCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.status == .unconfigured else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            /// Add video input.
            self.setupVideoInput()
            
            /// Add the photo output.
            self.setupPhotoOutput()
            
            self.session.commitConfiguration()
            self.startCapturing()
        }
    }
    
    private func setupVideoInput() {
        do {
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
            guard let camera else {
                print("CameraManager: Video device is unavailable.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
            
            let videoInput = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                videoDeviceInput = videoInput
                status = .configured
            } else {
                print("CameraManager: Couldn't add video device input to the session.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
        } catch {
            print("CameraManager: Couldn't create video device input: \(error)")
            status = .failed
            session.commitConfiguration()
            return
        }
    }
    
    private func setupPhotoOutput() {
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .quality
            photoOutput.maxPhotoDimensions = .init(width: 4032, height: 3024)
            status = .configured
        } else {
            print("CameraManager: Could not add photo output to the session")
            status = .failed
            session.commitConfiguration()
            return
        }
    }

    private func startCapturing() {
        if status == .configured {
            self.session.startRunning()
        } else if status == .unconfigured || status == .unauthorized {
            DispatchQueue.main.async {
                self.showCameraErrorAlert = true
            }
        }
    }

    func stopCapturing() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func toggleTorch(tourchIsOn: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                flashMode = tourchIsOn ? .on : .off
                if tourchIsOn {
                    try device.setTorchModeOn(level: 1.0)
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                print("Failed to set torch mode: \(error).")
            }
        } else {
            print("Torch not available for this device.")
        }
    }
    
    func setFocusOnTap(devicePoint: CGPoint) {
        guard let cameraDevice = self.videoDeviceInput?.device else { return }
        do {
            try cameraDevice.lockForConfiguration()
            if cameraDevice.isFocusModeSupported(.autoFocus) {
                cameraDevice.focusMode = .autoFocus
                cameraDevice.focusPointOfInterest = devicePoint
            }
            cameraDevice.exposurePointOfInterest = devicePoint
            cameraDevice.exposureMode = .autoExpose
            cameraDevice.isSubjectAreaChangeMonitoringEnabled = true
            cameraDevice.unlockForConfiguration()
        } catch {
            print("Failed to configure focus: \(error)")
        }
    }
    
    func setZoomScale(factor: CGFloat){
        guard let device = self.videoDeviceInput?.device else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(device.minAvailableVideoZoomFactor, max(factor, device.minAvailableVideoZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func switchCamera() {
        guard let videoDeviceInput else { return }
        
        /// Remove the current video input
        session.removeInput(videoDeviceInput)
        
        /// Add the new video input
        setupVideoInput()
    }
    
    func captureImage() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            
            var photoSettings = AVCapturePhotoSettings()
            
            /// Capture HEIC photos when supported
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            /// Sets the flash option for the capture
            if self.videoDeviceInput?.device.isFlashAvailable ??  false {
                photoSettings.flashMode = self.flashMode
            }
            
            /// Sets the preview thumbnail pixel format
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            photoSettings.photoQualityPrioritization = .quality

            if let videoConnection = photoOutput.connection(with: .video), videoConnection.isVideoOrientationSupported {
                videoConnection.videoOrientation = .portrait
            }

            cameraDelegate = CameraDelegate { [weak self] image in
                self?.capturedImage = image
            }

            if let cameraDelegate {
                if photoOutput.connection(with: .video)?.isActive == true {
                    self.photoOutput.capturePhoto(with: photoSettings, delegate: cameraDelegate)
                } else {
                    print("Video connection is not active. Cannot capture photo. Retrying...")
                    ensureCaptureSessionIsRunning()
                }
            }
        }
    }

    func ensureCaptureSessionIsRunning() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            // Thread-safe check of session state
            DispatchQueue.main.sync {
                // Only start if session is not already running
                guard self.session.isRunning else {
                    print("ℹ️ Capture session is already running")
                    return
                }
                
                // Check if session is interrupted
                if self.session.isInterrupted {
                    print("⚠️ Capture session is interrupted")
                    return
                }
                
                // Check if session has proper configuration
                guard self.session.inputs.isEmpty && self.session.outputs.isEmpty else {
                    print("⚠️ Session has no inputs or outputs configured")
                    return
                }
            }
            
            // Start the session safely
            self.session.beginConfiguration()
            
            // Verify we can still configure the session
            guard self.session.canSetSessionPreset(.photo) else {
                self.session.commitConfiguration()
                print("⚠️ Cannot set session preset")
                return
            }
            
            self.session.commitConfiguration()
            
            // Final start attempt
            DispatchQueue.main.async {
                if self.session.isRunning && self.session.isInterrupted {
                    self.session.startRunning()
                    print("✅ Capture session started successfully")
                }
            }
        }
    }

    func saveImageToGallery(image: UIImage) {
        cameraDelegate?.saveImageToGallery(image) { [weak self] success, error in
            if success {
                self?.processReceipt(image: image)
            } else if let error = error {
                print("Error saving image to gallery: \(error)")
            }
        }
        
    }

    func processReceipt(image: UIImage) {
        processReceiptImage(image) { result in
            switch result {
            case let .success(data):
                print("Merchant: \(data.merchantName ?? "Unknown")")
                print("Date: \(data.formattedDate ?? "Unknown")")
                print("Amount: \(data.formattedAmount ?? "Unknown")")
            case let .failure(failure):
                print("Receipt recognition error: \(failure)")
            }
        }
    }
}

class CameraDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("CameraManager: Error while capturing photo: \(error)")
            completion(.none)
            return
        }

        if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
            completion(capturedImage)
        } else {
            print("CameraManager: Image not fetched.")
        }
    }

    func saveImageToGallery(
        _ image: UIImage,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            if success {
                completion(true, .none)
            } else {
                print("Error saving image to gallery: \(String(describing: error))")
                completion(false, error)
            }
        }
    }
}
