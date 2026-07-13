import Vision
import CoreImage
import OSLog

enum VisionProcessorError: LocalizedError {
    case ciImageConversionFailed
    case requestExecutionFailed(String)

    var errorDescription: String? {
        switch self {
        case .ciImageConversionFailed:
            return "Could not convert pixel buffer to CIImage."
        case .requestExecutionFailed(let reason):
            return "Vision request failed: \(reason)"
        }
    }
}

final class VisionProcessor {
    private let model: VNCoreMLModel
    private let logger = Logger(subsystem: "com.naturetherapy.ai", category: "VisionProcessor")

    init(model: VNCoreMLModel) {
        self.model = model
    }

    func performDetection(on pixelBuffer: CVPixelBuffer) async throws -> [VNRecognizedObjectObservation] {
        logger.debug("Starting inference on pixel buffer")
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let results = try await performDetection(on: ciImage)
        logger.debug("Inference complete: \(results.count) observations")
        return results
    }

    func performDetection(on ciImage: CIImage) async throws -> [VNRecognizedObjectObservation] {
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFit

        let handler = VNImageRequestHandler(ciImage: ciImage,
                                              orientation: .up,
                                              options: [:])

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try handler.perform([request])
                let results = request.results as? [VNRecognizedObjectObservation] ?? []
                continuation.resume(returning: results)
            } catch {
                continuation.resume(throwing: VisionProcessorError.requestExecutionFailed(error.localizedDescription))
            }
        }
    }

    func performDetection(on cgImage: CGImage) async throws -> [VNRecognizedObjectObservation] {
        logger.debug("Starting inference on CGImage")
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFit

        let handler = VNImageRequestHandler(cgImage: cgImage,
                                              orientation: .up,
                                              options: [:])

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try handler.perform([request])
                let results = request.results as? [VNRecognizedObjectObservation] ?? []
                logger.debug("Inference complete: \(results.count) observations")
                continuation.resume(returning: results)
            } catch {
                continuation.resume(throwing: VisionProcessorError.requestExecutionFailed(error.localizedDescription))
            }
        }
    }
}
