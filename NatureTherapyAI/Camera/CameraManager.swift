import AVFoundation
import UIKit
import OSLog

enum CameraError: LocalizedError {
    case noCameraAvailable
    case permissionDenied
    case setupFailed(String)
    case captureFailed(String)
    case imageConversionFailed

    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "Tiada kamera tersedia pada peranti ini."
        case .permissionDenied:
            return "Akses kamera ditolak. Sila benarkan dalam Tetapan."
        case .setupFailed(let reason):
            return "Kamera gagal disediakan: \(reason)"
        case .captureFailed(let reason):
            return "Gagal mengambil gambar: \(reason)"
        case .imageConversionFailed:
            return "Gagal memproses gambar."
        }
    }
}

protocol CameraManagerDelegate: AnyObject {
    func cameraDidOutput(sampleBuffer: CMSampleBuffer)
    func cameraDidEncounterError(_ error: CameraError)
    func cameraDidCapturePhoto(_ image: UIImage)
}

final class CameraManager: NSObject {
    weak var delegate: CameraManagerDelegate?

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.naturetherapy.camera.session",
                                              qos: .userInitiated)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "com.naturetherapy.camera.video",
                                                       qos: .userInteractive)
    private let photoOutput = AVCapturePhotoOutput()
    private var _previewLayer: AVCaptureVideoPreviewLayer?
    private let logger = Logger(subsystem: "com.naturetherapy.camera", category: "CameraManager")
    private var isConfigured = false

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
        logger.info("CameraManager deinit")
    }

    func checkPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            logger.info("Requesting camera permission")
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied:
            logger.warning("Camera permission denied")
            return false
        case .restricted:
            logger.warning("Camera permission restricted")
            return false
        @unknown default:
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
            guard !self.session.isRunning else {
                self.logger.info("Camera session already running")
                return
            }
            self.logger.info("Starting camera session")
            if !self.isConfigured {
                self.configureSession()
            }
            self.session.startRunning()
            self.logger.info("Camera session started running")
        }
    }

    func stopCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.session.isRunning else { return }
            self.logger.info("Stopping camera session")
            self.session.stopRunning()
        }
    }

    func capturePhoto() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.session.isRunning else {
                self.logger.error("Cannot capture photo: session not running")
                self.delegate?.cameraDidEncounterError(.captureFailed("Kamera tidak aktif"))
                return
            }
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            self.photoOutput.capturePhoto(with: settings, delegate: self)
            self.logger.info("Photo capture requested")
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .back) else {
            logger.error("Cannot find rear camera")
            delegate?.cameraDidEncounterError(.setupFailed("Kamera belakang tidak dijumpai"))
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            guard session.canAddInput(input) else {
                logger.error("Cannot add camera input")
                delegate?.cameraDidEncounterError(.setupFailed("Tidak boleh tambah input kamera"))
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

        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        } else {
            logger.error("Cannot add video data output")
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            if let connection = photoOutput.connection(with: .video) {
                connection.videoRotationAngle = 90
            }
        } else {
            logger.error("Cannot add photo output")
        }

        if let connection = videoDataOutput.connection(with: .video) {
            connection.videoRotationAngle = 90
        }

        session.commitConfiguration()
        isConfigured = true
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
            if !self.session.isRunning && self.isConfigured {
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

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error {
            logger.error("Photo capture error: \(error.localizedDescription, privacy: .public)")
            delegate?.cameraDidEncounterError(.captureFailed(error.localizedDescription))
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            logger.error("Cannot get photo data representation")
            delegate?.cameraDidEncounterError(.imageConversionFailed)
            return
        }

        guard let image = UIImage(data: data) else {
            logger.error("Cannot create UIImage from photo data")
            delegate?.cameraDidEncounterError(.imageConversionFailed)
            return
        }

        logger.info("Photo captured successfully: \(data.count) bytes")
        delegate?.cameraDidCapturePhoto(image)
    }
}
