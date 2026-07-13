import Vision
import CoreImage
import CoreGraphics
import OSLog

final class ObjectDetector: ObservableObject {
    @Published var latestResults: [DetectionResult] = []
    @Published var isModelLoaded = false
    @Published var detectionError: String?
    @Published var isProcessing = false

    private var visionProcessor: VisionProcessor?
    private let logger = Logger(subsystem: "com.naturetherapy.ai", category: "ObjectDetector")
    private let processingLock = NSLock()

    init() {
        loadModel()
    }

    func loadModel() {
        do {
            let model = try ModelHandler.shared.loadModel()
            visionProcessor = VisionProcessor(model: model)
            isModelLoaded = true
            detectionError = nil
            logger.info("Model loaded successfully")
        } catch {
            isModelLoaded = false
            visionProcessor = nil
            detectionError = error.localizedDescription
            logger.error("Model loading failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func detectObjects(in pixelBuffer: CVPixelBuffer) async -> [DetectionResult] {
        processingLock.lock()
        if isProcessing {
            processingLock.unlock()
            logger.debug("Frame skipped — previous inference still running")
            return []
        }
        isProcessing = true
        processingLock.unlock()

        defer {
            processingLock.lock()
            isProcessing = false
            processingLock.unlock()
        }

        guard let processor = visionProcessor else {
            await MainActor.run {
                self.detectionError = "AI model not loaded. Add NatureDetection.mlmodel to the project."
            }
            logger.error("Cannot detect: model not loaded")
            return []
        }

        do {
            let observations = try await processor.performDetection(on: pixelBuffer)
            let results = observations.map { convertObservation($0) }
            logger.info("Detection complete: \(results.count) objects found")
            await MainActor.run {
                self.latestResults = results
                self.detectionError = nil
            }
            return results
        } catch {
            logger.error("Detection failed: \(error.localizedDescription, privacy: .public)")
            await MainActor.run {
                self.detectionError = error.localizedDescription
            }
            return []
        }
    }

    func detectObjects(in cgImage: CGImage) async -> [DetectionResult] {
        processingLock.lock()
        if isProcessing {
            processingLock.unlock()
            logger.debug("Frame skipped — previous inference still running")
            return []
        }
        isProcessing = true
        processingLock.unlock()

        defer {
            processingLock.lock()
            isProcessing = false
            processingLock.unlock()
        }

        guard let processor = visionProcessor else {
            await MainActor.run {
                self.detectionError = "AI model not loaded. Add NatureDetection.mlmodel to the project."
            }
            logger.error("Cannot detect: model not loaded")
            return []
        }

        do {
            let observations = try await processor.performDetection(on: cgImage)
            let results = observations.map { convertObservation($0) }
            logger.info("Detection complete: \(results.count) objects found")
            await MainActor.run {
                self.latestResults = results
                self.detectionError = nil
            }
            return results
        } catch {
            logger.error("Detection failed: \(error.localizedDescription, privacy: .public)")
            await MainActor.run {
                self.detectionError = error.localizedDescription
            }
            return []
        }
    }

    private func convertObservation(_ observation: VNRecognizedObjectObservation) -> DetectionResult {
        let label = observation.labels.first?.identifier ?? "Unknown"
        let confidence = observation.labels.first?.confidence ?? 0
        return DetectionResult(
            objectName: label,
            confidence: confidence,
            boundingBox: observation.boundingBox
        )
    }
}
