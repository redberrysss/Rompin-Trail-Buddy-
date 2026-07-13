import SwiftUI
import CoreImage
import OSLog

final class SimulatorCameraManager: ObservableObject {
    @Published var currentImage: CGImage?
    @Published var isRunning = false
    @Published var modelError: String?

    private var timer: Timer?
    private var frameIndex = 0
    private var currentPreset = 0
    private let objectDetector: ObjectDetector
    private let onDetections: ([DetectionResult]) -> Void
    private let logger = Logger(subsystem: "com.naturetherapy.simulator", category: "SimulatorCamera")

    private let sampleNames = [
        "sample_forest", "sample_river", "sample_garden", "sample_wildlife"
    ]

    init(objectDetector: ObjectDetector, onDetections: @escaping ([DetectionResult]) -> Void) {
        self.objectDetector = objectDetector
        self.onDetections = onDetections
    }

    func startSimulatorCamera() {
        stopSimulatorCamera()
        isRunning = true
        frameIndex = 0
        processCurrentPreset()

        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.processCurrentPreset()
        }
    }

    func stopSimulatorCamera() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func selectPreset(_ index: Int) {
        currentPreset = index % sampleNames.count
        frameIndex = 0
        if isRunning {
            processCurrentPreset()
        }
    }

    private func processCurrentPreset() {
        guard let image = loadSampleImage(for: currentPreset) else {
            modelError = "Sample image not found. Add \(self.sampleNames[currentPreset]).jpg to the app bundle."
            logger.error("Sample image missing: \(self.sampleNames[self.currentPreset])")
            return
        }
        currentImage = image
        modelError = nil

        Task {
            let results = await objectDetector.detectObjects(in: image)
            await MainActor.run {
                self.onDetections(results)
            }
        }
        frameIndex += 1
    }

    private func loadSampleImage(for preset: Int) -> CGImage? {
        let name = sampleNames[preset % sampleNames.count]
        guard let url = Bundle.main.url(forResource: name, withExtension: "jpg") ?? Bundle.main.url(forResource: name, withExtension: "jpeg") ?? Bundle.main.url(forResource: name, withExtension: "png") else {
            return nil
        }
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
        }
        logger.info("Loaded sample image: \(name)")
        return cgImage
    }
}
