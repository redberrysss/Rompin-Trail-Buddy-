import SwiftUI
import SwiftData
import CoreImage
import AVFoundation
import OSLog

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var detections: [DetectionResult] = []
    @Published var detectedObject: NatureObject?
    @Published var showDiscovery = false
    @Published var cameraError: String?
    @Published var isCameraReady = false
    @Published var isSimulatorMode = false
    @Published var currentFrame: CGImage?

    @Published var capturedImage: UIImage?
    @Published var showPreview = false
    @Published var isUploading = false
    @Published var uploadStatus: String?
    @Published var uploadError: String?

    let objectDetector = ObjectDetector()
    private var cameraManager: CameraManager?
    var simulatorCamera: SimulatorCameraManager?

    private var modelContext: ModelContext?
    private let logger = Logger(subsystem: "com.rompinforest.camera", category: "CameraViewModel")

    var cameraSession: AVCaptureSession? {
        #if targetEnvironment(simulator)
        nil
        #else
        cameraManager?.session
        #endif
    }

    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext

        #if targetEnvironment(simulator)
        isSimulatorMode = true
        simulatorCamera = SimulatorCameraManager(objectDetector: objectDetector) { [weak self] results in
            DispatchQueue.main.async {
                self?.detections = results
            }
        }
        isCameraReady = true
        #else
        let manager = CameraManager()
        manager.delegate = self
        cameraManager = manager
        #endif
    }

    func startCamera() {
        #if targetEnvironment(simulator)
        simulatorCamera?.startSimulatorCamera()
        #else
        guard cameraManager?.session.isRunning != true else {
            isCameraReady = true
            return
        }
        Task {
            do {
                try await cameraManager?.startCamera()
                isCameraReady = true
                cameraError = nil
            } catch let error as CameraError {
                cameraError = error.localizedDescription
                logger.error("Camera start error: \(error.localizedDescription)")
            } catch {
                cameraError = error.localizedDescription
                logger.error("Camera start error: \(error.localizedDescription)")
            }
        }
        #endif
    }

    func stopCamera() {
        #if targetEnvironment(simulator)
        simulatorCamera?.stopSimulatorCamera()
        #else
        cameraManager?.stopCamera()
        #endif
    }

    func capturePhoto() {
        #if targetEnvironment(simulator)
        capturedImage = simulatorCamera?.capturePhoto()
        if capturedImage != nil {
            showPreview = true
            stopCamera()
        }
        #else
        guard let manager = cameraManager else {
            cameraError = "Kamera tidak tersedia"
            return
        }
        manager.capturePhoto()
        #endif
    }

    func retakePhoto() {
        capturedImage = nil
        showPreview = false
        uploadError = nil
        uploadStatus = nil
        startCamera()
    }

    func savePhoto(discoveryName: String = "Penemuan Baru", category: String = "alam") async {
        guard let image = capturedImage else {
            uploadError = "Tiada gambar untuk disimpan"
            return
        }
        guard let userId = AuthenticationService.shared.currentUser?.uid else {
            uploadError = "Sila log masuk untuk menyimpan"
            return
        }

        isUploading = true
        uploadStatus = "Menyediakan..."
        uploadError = nil

        do {
            uploadStatus = "Memuat naik ke awan..."
            let imageId = UUID().uuidString
            let result = try await FirebaseStorageService.shared.uploadImage(
                image: image,
                userId: userId,
                participantId: userId,
                activityNumber: 1,
                imageId: imageId
            )

            uploadStatus = "Menyimpan rekod..."
            try await saveToFirestore(
                userId: userId,
                imageId: imageId,
                storagePath: result.storagePath,
                downloadURL: result.downloadURL,
                objectName: discoveryName,
                category: category
            )

            if let context = modelContext {
                saveToLocalDatabase(
                    image: image,
                    imagePath: result.storagePath,
                    objectName: discoveryName,
                    category: category,
                    context: context
                )
            }

            uploadStatus = "Disimpan!"
            isUploading = false
            showPreview = false
            capturedImage = nil

            try? await Task.sleep(nanoseconds: 800_000_000)
            uploadStatus = nil
        } catch {
            uploadError = error.localizedDescription
            logger.error("Upload failed: \(error.localizedDescription)")
            isUploading = false
            uploadStatus = "Gagal"

            if let context = modelContext {
                savePendingUpload(
                    image: image,
                    userId: userId,
                    objectName: discoveryName,
                    category: category,
                    context: context
                )
            }
        }
    }

    private func saveToFirestore(userId: String, imageId: String, storagePath: String, downloadURL: String, objectName: String, category: String) async throws {
        #if canImport(FirebaseFirestore)
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId).collection("discoveries").document(imageId)
        try await docRef.setData([
            "id": imageId,
            "userId": userId,
            "activityNumber": 1,
            "category": category,
            "objectName": objectName,
            "imageStoragePath": storagePath,
            "imageDownloadURL": downloadURL,
            "isConfirmed": false,
            "isSkipped": false,
            "uploadStatus": "complete",
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ])
        #endif
    }

    private func saveToLocalDatabase(image: UIImage, imagePath: String, objectName: String, category: String, context: ModelContext) {
        let localPath = ImageStorageService.shared.savePhoto(image: image)
        let record = ObservationRecord(
            sessionID: UUID(),
            participantID: UUID(),
            activityNumber: 1,
            category: category,
            objectName: objectName
        )
        record.imagePath = localPath ?? imagePath
        record.isConfirmed = true
        context.insert(record)
        try? context.save()
    }

    private func savePendingUpload(image: UIImage, userId: String, objectName: String, category: String, context: ModelContext) {
        if let localPath = ImageStorageService.shared.savePhoto(image: image) {
            let task = PendingUploadTask(
                ownerId: userId,
                participantId: userId,
                activityNumber: 1,
                localFilePath: localPath,
                storageDestinationPath: "users/\(userId)/discoveries/\(UUID().uuidString).jpg",
                recordType: "observation",
                recordPayload: "{\"objectName\": \"\(objectName)\", \"category\": \"\(category)\"}"
            )
            PendingUploadService.shared.saveTask(task, context: context)
        }
    }

    func showDiscoveryFor(detection: DetectionResult) {
        let sample = NatureObject.sample(for: detection.objectName)
        detectedObject = sample
        showDiscovery = true

        if let context = modelContext {
            DetectionService.shared.processDetections([detection], modelContext: context)
        }
    }
}

#if !targetEnvironment(simulator)
import CoreMedia
import CoreVideo

extension CameraViewModel: CameraManagerDelegate {
    nonisolated func cameraDidOutput(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        Task { @MainActor in
            let results = await objectDetector.detectObjects(in: pixelBuffer)
            self.detections = results
        }
    }

    nonisolated func cameraDidEncounterError(_ error: CameraError) {
        Task { @MainActor in
            self.cameraError = error.localizedDescription
        }
    }

    nonisolated func cameraDidCapturePhoto(_ image: UIImage) {
        Task { @MainActor in
            self.capturedImage = image
            self.showPreview = true
            self.stopCamera()
        }
    }
}
#endif
