import AVFoundation
import UIKit
import OSLog

enum CameraError: LocalizedError {
    case noCameraAvailable
    case permissionDenied
    case setupFailed(String)

    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "No camera available on this device."
        case .permissionDenied:
            return "Camera permission was denied. Please enable it in Settings."
        case .setupFailed(let reason):
            return "Camera setup failed: \(reason)"
        }
    }
}

protocol CameraManagerDelegate: AnyObject {
    func cameraDidOutput(sampleBuffer: CMSampleBuffer)
    func cameraDidEncounterError(_ error: CameraError)
}

final class CameraManager: NSObject {
    weak var delegate: CameraManagerDelegate?

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.naturetherapy.camera.session",
                                              qos: .userInitiated)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "com.naturetherapy.camera.video",
                                                      qos: .userInteractive)
    private var _previewLayer: AVCaptureVideoPreviewLayer?
    private let logger = Logger(subsystem: "com.naturetherapy.camera", category: "CameraManager")

    var previewLayer: AVCaptureVideoPreviewLayer {
        if let existing = _previewLayer {
            return existing
        }
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        _previewLayer = layer
        return layer
    }

    override init() {
        super.init()
        addLifecycleObservers()
    }

    deinit {
        removeLifecycleObservers()
    }

    func checkPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    func startCamera() async throws {
        let granted = await checkPermission()
        guard granted else {
            throw CameraError.permissionDenied
        }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.logger.info("Starting camera session")
            self.configureSession()
            self.session.startRunning()
            self.logger.info("Camera session started running")
        }
    }

    func stopCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.logger.info("Stopping camera session")
            self.session.stopRunning()
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .back) else {
            logger.error("Cannot find rear camera")
            delegate?.cameraDidEncounterError(.setupFailed("Cannot find rear camera"))
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            guard session.canAddInput(input) else {
                logger.error("Cannot add camera input")
                delegate?.cameraDidEncounterError(.setupFailed("Cannot add camera input"))
                session.commitConfiguration()
                return
            }
            session.addInput(input)
        } catch {
            logger.error("Camera input setup failed: \(error.localizedDescription, privacy: .public)")
            delegate?.cameraDidEncounterError(.setupFailed(error.localizedDescription))
            session.commitConfiguration()
            return
        }

        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

        guard session.canAddOutput(videoDataOutput) else {
            logger.error("Cannot add video output")
            delegate?.cameraDidEncounterError(.setupFailed("Cannot add video output"))
            session.commitConfiguration()
            return
        }
        session.addOutput(videoDataOutput)

        if let connection = videoDataOutput.connection(with: .video) {
            connection.videoRotationAngle = 90
        }

        session.commitConfiguration()
        logger.info("Camera session configured successfully")
    }

    // MARK: - Lifecycle

    private func addLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func removeLifecycleObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc private func handleWillResignActive() {
        logger.info("App will resign active — stopping camera")
        stopCamera()
    }

    @objc private func handleDidBecomeActive() {
        logger.info("App did become active — restarting camera")
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
                self.logger.info("Camera restarted after foreground")
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        delegate?.cameraDidOutput(sampleBuffer: sampleBuffer)
    }
}
