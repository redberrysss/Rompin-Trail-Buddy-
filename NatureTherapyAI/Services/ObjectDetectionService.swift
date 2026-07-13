import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreMedia
import OSLog
import Combine

@MainActor
final class ObjectDetectionService: ObservableObject {
    static let shared = ObjectDetectionService()

    @Published var isProcessing = false
    @Published var modelStatus = "Not initialized"

    private let objectDetector = ObjectDetector()
    private let logger = Logger(subsystem: "com.rompinforest.detection", category: "ObjectDetectionService")
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    private var cancellables = Set<AnyCancellable>()

    private init() {
        objectDetector.$isModelLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loaded in
                self?.modelStatus = loaded ? "Core ML model loaded" : "Core ML model not available — use RoboflowAPIService as fallback"
            }
            .store(in: &cancellables)

        objectDetector.$detectionError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.logger.error("ObjectDetector reported error: \(error, privacy: .public)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Single highest-confidence detection

    func detectObject(in image: UIImage) async -> DetectionResult? {
        let results = await detectObjects(in: image)
        return results.max(by: { $0.confidence < $1.confidence })
    }

    // MARK: - All detections

    func detectObjects(in image: UIImage) async -> [DetectionResult] {
        await MainActor.run { isProcessing = true }
        defer { Task { @MainActor in isProcessing = false } }

        guard let cgImage = image.cgImage else {
            logger.error("Failed to obtain CGImage from UIImage")
            return []
        }

        let results = await objectDetector.detectObjects(in: cgImage)
        logger.info("Returning \(results.count) detection results")
        return results
    }

    // MARK: - OCR via Vision

    func performOCR(on image: UIImage) async -> String {
        await MainActor.run { isProcessing = true }
        defer { Task { @MainActor in isProcessing = false } }

        guard let cgImage = image.cgImage else {
            logger.error("Failed to obtain CGImage for OCR")
            return ""
        }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { [logger] request, error in
                if let error {
                    logger.error("OCR request failed: \(error.localizedDescription, privacy: .public)")
                    continuation.resume(returning: "")
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                let combined = recognizedStrings.joined(separator: "\n")
                continuation.resume(returning: combined)
            }

            request.recognitionLevel = .fast
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                logger.error("Failed to perform OCR handler: \(error.localizedDescription, privacy: .public)")
                continuation.resume(returning: "")
            }
        }
    }
}
