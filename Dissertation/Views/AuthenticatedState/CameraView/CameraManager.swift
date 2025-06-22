import Photos
import PhotosUI
import SwiftUI
import AVFoundation
import Combine

enum CameraStatus {
    case configured
    case unconfigured
    case unauthorized
    case failed
}

class CameraManager: ObservableObject {
    // MARK: - Published Properties
    @Published var capturedImage: UIImage? = nil
    @Published var status = CameraStatus.unconfigured
    @Published var showCameraErrorAlert = false
    @Published var showPhotoErrorAlert = false
    @Published var showSettingAlert = false
    @Published var isPermissionGranted: Bool = false
    @Published var isFlashOn = false
    @Published var selectedPhotos: [PhotosPickerItem] = []
    
    // MARK: - Camera Properties
    let session = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var videoDeviceInput: AVCaptureDeviceInput?
    var position: AVCaptureDevice.Position = .back
    
    // MARK: - Private Properties
    private var flashMode: AVCaptureDevice.FlashMode = .off
    private var cameraDelegate: CameraDelegate?
    private let sessionQueue = DispatchQueue(label: "com.FundBud.sessionQueue")
    private var cancelables = Set<AnyCancellable>()
    private var isConfiguring = false
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    deinit {
        stopCapturing()
        cancelables.removeAll()
    }
    
    private func setupBindings() {
        $isFlashOn
            .sink { [weak self] isOn in
                self?.flashMode = isOn ? .on : .off
            }
            .store(in: &cancelables)
    }

    // MARK: - Permission Management
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isPermissionGranted = isGranted
                if isGranted {
                    self.setupCamera()
                } else {
                    self.showSettingAlert = true
                }
            }
        }
    }
    
    func checkForDevicePermission() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch videoStatus {
        case .authorized:
            DispatchQueue.main.async {
                self.isPermissionGranted = true
            }
            setupCamera()
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isPermissionGranted = false
                self.showSettingAlert = true
            }
        @unknown default:
            DispatchQueue.main.async {
                self.isPermissionGranted = false
                self.showSettingAlert = true
            }
        }
    }
    
    func requestGalleryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    break
                case .denied, .restricted:
                    self?.showSettingAlert = true
                default:
                    break
                }
            }
        }
    }
    
    func checkGalleryPermissionStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }

    // MARK: - Camera Setup (SIMPLIFIED)
    private func setupCamera() {
        guard !isConfiguring else { return }
        isConfiguring = true
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Configure session only once
            if self.session.inputs.isEmpty && self.session.outputs.isEmpty {
                self.session.sessionPreset = .photo
                
                // Add photo output
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
            }
            
            // Setup camera input
            self.setupCameraInput()
            
            // Start session
            if !self.session.isRunning {
                self.session.startRunning()
                
                DispatchQueue.main.async {
                    self.status = .configured
                    self.isConfiguring = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isConfiguring = false
                }
            }
        }
    }
    
    private func setupCameraInput() {
        // Remove existing video input
        if let existingInput = videoDeviceInput {
            session.removeInput(existingInput)
        }
        
        // Get camera for current position
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(input) {
                session.addInput(input)
                videoDeviceInput = input
            }
        } catch {}
    }

    // MARK: - Session Control
    func stopCapturing() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    // MARK: - Camera Controls
    func switchCamera() {
        guard !isConfiguring else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Simply switch position and update input
            self.position = (self.position == .back) ? .front : .back
            
            // Update camera input without stopping session
            self.setupCameraInput()
        }
    }
    
    func switchFlash() {
        isFlashOn.toggle()
        toggleTorch(torchIsOn: isFlashOn)
    }
    
    private func toggleTorch(torchIsOn: Bool) {
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let device = self.videoDeviceInput?.device,
                  device.hasTorch else {
                return
            }
            
            do {
                try device.lockForConfiguration()
                if torchIsOn {
                    try device.setTorchModeOn(level: 1.0)
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {}
        }
    }
    
    func setFocus(point: CGPoint) {
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let device = self.videoDeviceInput?.device else { return }
            
            do {
                try device.lockForConfiguration()
                
                if device.isFocusModeSupported(.autoFocus) {
                    device.focusMode = .autoFocus
                    device.focusPointOfInterest = point
                }
                
                if device.isExposureModeSupported(.autoExpose) {
                    device.exposureMode = .autoExpose
                    device.exposurePointOfInterest = point
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = true
                device.unlockForConfiguration()
            } catch {
            }
        }
    }
    
    func zoom(with factor: CGFloat) {
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let device = self.videoDeviceInput?.device else { return }
            
            do {
                try device.lockForConfiguration()
                let clampedFactor = max(device.minAvailableVideoZoomFactor,
                                      min(factor, device.maxAvailableVideoZoomFactor))
                device.videoZoomFactor = clampedFactor
                device.unlockForConfiguration()
            } catch {}
        }
    }
    
    // MARK: - Photo Capture
    func captureImage() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard self.status == .configured,
                  self.session.isRunning else {
                return
            }
            
            guard let videoConnection = self.photoOutput.connection(with: .video) else {
                return
            }
            
            let photoSettings = AVCapturePhotoSettings()
            
            if let device = self.videoDeviceInput?.device, device.isFlashAvailable {
                photoSettings.flashMode = self.flashMode
            }
            
            if videoConnection.isVideoOrientationSupported {
                videoConnection.videoOrientation = .portrait
            }
            
            self.cameraDelegate = CameraDelegate { [weak self] image in
                DispatchQueue.main.async {
                    self?.capturedImage = image
                }
            }
            
            if let delegate = self.cameraDelegate {
                self.photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
            }
        }
    }

    // MARK: - Image Processing
    func saveImageToGallery(image: UIImage) {
        let delegate = CameraDelegate { _ in }
        delegate.saveImageToGallery(image) { [weak self] _, error in
            DispatchQueue.main.async {
                if let _ = error {
                    self?.showPhotoErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Camera Delegate
class CameraDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            completion(nil)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let capturedImage = UIImage(data: imageData) else {
            completion(nil)
            return
        }

        completion(capturedImage)
    }

    func saveImageToGallery(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            performSave(image, completion: completion)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    self.performSave(image, completion: completion)
                } else {
                    completion(false, NSError(domain: "PhotoLibraryError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]))
                }
            }
        case .denied, .restricted:
            completion(false, NSError(domain: "PhotoLibraryError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"]))
        @unknown default:
            completion(false, NSError(domain: "PhotoLibraryError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unknown photo library authorization status"]))
        }
    }
    
    private func performSave(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
