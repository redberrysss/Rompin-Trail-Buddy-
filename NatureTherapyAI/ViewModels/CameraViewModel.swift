import SwiftUI
import SwiftData
import CoreImage
import AVFoundation

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var detections: [DetectionResult] = []
    @Published var detectedObject: NatureObject?
    @Published var showDiscovery = false
    @Published var cameraError: String?
    @Published var isCameraReady = false
    @Published var isSimulatorMode = false
    @Published var currentFrame: CGImage?

    let objectDetector = ObjectDetector()
    private var cameraManager: CameraManager?
    var simulatorCamera: SimulatorCameraManager?

    private var modelContext: ModelContext?

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
        Task {
            do {
                try await cameraManager?.startCamera()
                isCameraReady = true
                cameraError = nil
            } catch let error as CameraError {
                cameraError = error.localizedDescription
            } catch {
                cameraError = error.localizedDescription
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
}
#endif
