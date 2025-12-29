import Foundation
import Flutter
import UIKit
import AVFoundation

class NativeYoloView: NSObject, FlutterPlatformView, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    private var _view: UIView
    private var channel: FlutterMethodChannel
    
    // Components
    private var session: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var overlayView: OverlayView
    private var detector: Detector?
    
    // Thread Safety for Camera
    private let sessionQueue = DispatchQueue(label: "camera_session_queue")
    
    // State
    private var isFrontCamera = false
    private var streamDetections = false
    private var detectionEnabled = true
    private var throttleMs: Int64 = 50
    private var lastSendTime: Int64 = 0
    private var latestRawBoxes: [BoundingBox] = []
    
    // Assets
    private var modelAssetPath = "assets/model3.tflite"
    private var labelAssetPath = "assets/labels.txt"
    
    // Photo Capture
    private var photoOutput = AVCapturePhotoOutput()
    private var photoCaptureCallback: ((String?, String?) -> Void)?
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger messenger: FlutterBinaryMessenger) {
        self._view = UIView(frame: frame)
        self.channel = FlutterMethodChannel(name: "native-left-view/\(viewId)", binaryMessenger: messenger)
        self.overlayView = OverlayView(frame: frame)
        
        super.init()
        
        if let params = args as? [String: Any] {
            if let mp = params["modelPath"] as? String { self.modelAssetPath = mp }
            if let lp = params["labelPath"] as? String { self.labelAssetPath = lp }
        }
        
        setupUI()
        setupMethodChannel()
        initializeDetector()
        
        checkPermissionsAndStart()
    }
    
    func view() -> UIView {
        return _view
    }
    
    private func setupUI() {
        _view.backgroundColor = .black
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _view.addSubview(overlayView)
    }
    
    private func initializeDetector() {
        print("🔍 NATIVE: Looking up assets: \(modelAssetPath) & \(labelAssetPath)")
        
        let keyModel = FlutterDartProject.lookupKey(forAsset: modelAssetPath)
        let keyLabel = FlutterDartProject.lookupKey(forAsset: labelAssetPath)
        
        guard let modelPath = Bundle.main.path(forResource: keyModel, ofType: nil) else {
            print("❌ NATIVE ERROR: Could not find '\(modelAssetPath)' in bundle.")
            return
        }
        
        guard let labelPath = Bundle.main.path(forResource: keyLabel, ofType: nil) else {
            print("❌ NATIVE ERROR: Could not find '\(labelAssetPath)' in bundle.")
            return
        }
        
        detector = Detector(modelPath: modelPath, labelPath: labelPath)
    }
    
    private func setupMethodChannel() {
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
    }
    
    private func checkPermissionsAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sessionQueue.async { self.setupCamera() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.sessionQueue.async { self.setupCamera() }
                }
            }
        default:
            print("Camera Permission denied in NativeView")
        }
    }
    
    // Executed on sessionQueue
    private func setupCamera() {
        let session = AVCaptureSession()
        
        // Use photo preset for best quality
        if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
        }
        
        // 1. Input
        guard let device = getCamera(front: isFrontCamera),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Could not create camera input")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("Failed to add input")
            return
        }
        
        // 2. Video Output (For Detection)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        // Force BGRA for Detector
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing"))
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                if isFrontCamera && connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }
        }
        
        // 3. Photo Output
        self.photoOutput = AVCapturePhotoOutput()
        
        // --- FIX: Enable High Res Capture on the Output itself ---
        self.photoOutput.isHighResolutionCaptureEnabled = true
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        // 4. Preview Layer (UI Main Thread)
        DispatchQueue.main.async {
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            self.videoPreviewLayer?.videoGravity = .resizeAspectFill
            self.videoPreviewLayer?.connection?.videoOrientation = .portrait
            self.videoPreviewLayer?.frame = self._view.bounds
            
            if let layer = self.videoPreviewLayer {
                self._view.layer.insertSublayer(layer, at: 0)
            }
        }
        
        // 5. Start
        session.startRunning()
        self.session = session
        print("✅ Camera Setup Complete & Running")
    }
    
    private func getCamera(front: Bool) -> AVCaptureDevice? {
        let position: AVCaptureDevice.Position = front ? .front : .back
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first
    }
    
    // MARK: - Method Channel Handler
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setStreamDetections":
            if let args = call.arguments as? [String: Any] {
                streamDetections = args["enabled"] as? Bool ?? false
                throttleMs = Int64(args["throttleMs"] as? Int ?? 50)
            }
            result(nil)
            
        case "setTorch":
            let enabled = (call.arguments as? [String: Any])?["enabled"] as? Bool ?? false
            sessionQueue.async { self.toggleTorch(on: enabled) }
            result(nil)
            
        case "setFrontCamera":
            let front = (call.arguments as? [String: Any])?["front"] as? Bool ?? false
            if front != isFrontCamera {
                isFrontCamera = front
                sessionQueue.async {
                    self.session?.stopRunning()
                    self.videoPreviewLayer?.removeFromSuperlayer()
                    self.setupCamera()
                }
            }
            result(nil)
            
        case "setOverlayVisible":
            let visible = (call.arguments as? [String: Any])?["visible"] as? Bool ?? true
            DispatchQueue.main.async { self.overlayView.isHidden = !visible }
            result(nil)
            
        case "setDetectionEnabled":
            detectionEnabled = (call.arguments as? [String: Any])?["enabled"] as? Bool ?? true
            result(nil)
            
        case "detectFromImage":
            if let args = call.arguments as? [String: Any], let path = args["path"] as? String {
                if let image = UIImage(contentsOfFile: path) {
                    if let det = detector {
                        let res = det.detect(image: image)
                        result(processBoxesToFlatArray(res.boxes))
                    } else {
                        result(FlutterError(code: "INIT_ERROR", message: "Detector not initialized", details: nil))
                    }
                } else {
                    result(FlutterError(code: "IO", message: "File not found", details: nil))
                }
            } else {
                result(FlutterError(code: "ARGS", message: "Missing path argument", details: nil))
            }
            
        case "capturePhoto":
            sessionQueue.async {
                guard let session = self.session, session.isRunning else {
                    DispatchQueue.main.async { result(FlutterError(code: "CAMERA_OFF", message: "Camera not running", details: nil)) }
                    return
                }
                
                guard let connection = self.photoOutput.connection(with: .video), connection.isActive else {
                    DispatchQueue.main.async { result(FlutterError(code: "CONNECTION_ERROR", message: "No active video connection", details: nil)) }
                    return
                }

                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                
                let settings = AVCapturePhotoSettings()
                // Now safe to enable this because we enabled it on the output in setupCamera
                if self.photoOutput.isHighResolutionCaptureEnabled {
                    settings.isHighResolutionPhotoEnabled = true
                }
                
                self.photoCaptureCallback = { path, error in
                    if let err = error {
                         DispatchQueue.main.async { result(FlutterError(code: "CAPTURE_ERROR", message: err, details: nil)) }
                    } else {
                        let detections = self.processBoxesToFlatArray(self.latestRawBoxes)
                         DispatchQueue.main.async {
                            result([
                                "path": path ?? "",
                                "detections": detections
                            ])
                        }
                    }
                }
                
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = getCamera(front: isFrontCamera), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    // MARK: - Video Frame Delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !detectionEnabled { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Sync detection
        guard let result = detector?.detect(pixelBuffer: pixelBuffer) else { return }
        let boxes = result.boxes
        
        self.latestRawBoxes = boxes
        
        DispatchQueue.main.async {
            self.overlayView.results = boxes
        }
        
        if streamDetections {
            let now = Int64(Date().timeIntervalSince1970 * 1000)
            if now - lastSendTime >= throttleMs {
                lastSendTime = now
                if !boxes.isEmpty {
                    let data = processBoxesToFlatArray(boxes)
                    DispatchQueue.main.async {
                        self.channel.invokeMethod("onDetections", arguments: data)
                    }
                }
            }
        }
    }
    
    private func processBoxesToFlatArray(_ boxes: [BoundingBox]) -> [String: Any] {
        var circles: [Double] = []
        var eyes: [Double] = []
        
        for b in boxes {
            if b.clsName.lowercased().contains("circle") {
                circles.append(Double(b.cx))
                circles.append(Double(b.cy))
            } else if b.clsName.lowercased().contains("eye") {
                eyes.append(Double(b.cx))
                eyes.append(Double(b.cy))
            }
        }
        
        return [
            "circles": circles,
            "eyes": eyes
        ]
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            photoCaptureCallback?(nil, error?.localizedDescription)
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            photoCaptureCallback?(nil, "No photo data")
            return
        }
        
        let filename = "IMG_\(Int(Date().timeIntervalSince1970)).jpg"
        let tempDir = FileManager.default.temporaryDirectory
        let fileUrl = tempDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileUrl)
            photoCaptureCallback?(fileUrl.path, nil)
        } catch {
            photoCaptureCallback?(nil, error.localizedDescription)
        }
    }
}
