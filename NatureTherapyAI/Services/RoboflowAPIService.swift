import UIKit
import OSLog
import Foundation

@MainActor
final class RoboflowAPIService: ObservableObject {
    static let shared = RoboflowAPIService()

    @Published var isProcessing = false
    @Published var lastError: String?

    private var apiKey = "your-roboflow-api-key"
    private var workspace = "your-workspace"
    private var project = "nature-therapy-ai"
    private var version = 1
    private let baseHost = "https://detect.roboflow.com"
    private let session: URLSession
    private let logger = Logger(subsystem: "com.rompinforest.detection", category: "RoboflowAPI")

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    // MARK: - Configuration

    func configure(apiKey: String, workspace: String, project: String, version: Int) {
        self.apiKey = apiKey
        self.workspace = workspace
        self.project = project
        self.version = version
        logger.info("Roboflow API configured for \(workspace)/\(project) v\(version)")
    }

    // MARK: - Prediction Types

    struct RoboflowPrediction: Codable, Sendable {
        let `class`: String
        let confidence: Float
        let x: Float
        let y: Float
        let width: Float
        let height: Float

        var boundingBox: CGRect {
            CGRect(
                x: CGFloat(x - width / 2),
                y: CGFloat(y - height / 2),
                width: CGFloat(width),
                height: CGFloat(height)
            )
        }

        func toDetectionResult() -> DetectionResult {
            DetectionResult(
                objectName: `class`,
                confidence: confidence,
                boundingBox: boundingBox
            )
        }
    }

    private struct RoboflowResponse: Codable {
        let predictions: [RoboflowPrediction]
    }

    // MARK: - Detection

    func detect(image: UIImage) async -> [RoboflowPrediction] {
        await MainActor.run { isProcessing = true }
        defer { Task { @MainActor in isProcessing = false } }

        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            await MainActor.run { lastError = "Failed to compress image to JPEG" }
            logger.error("Failed to create JPEG data from image")
            return []
        }

        let base64String = jpegData.base64EncodedString()

        guard let url = buildEndpointURL() else {
            await MainActor.run { lastError = "Invalid API endpoint URL" }
            logger.error("Failed to construct endpoint URL")
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let bodyString = "image=\(base64String)"
        request.httpBody = bodyString.data(using: .utf8)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { lastError = "Invalid response type" }
                return []
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let body = String(data: data, encoding: .utf8) ?? "No body"
                let msg = "API returned status \(httpResponse.statusCode): \(body)"
                await MainActor.run { lastError = msg }
                logger.error("\(msg, privacy: .public)")
                return []
            }

            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(RoboflowResponse.self, from: data)

            logger.info("Roboflow detection returned \(apiResponse.predictions.count) predictions")
            await MainActor.run { lastError = nil }

            return apiResponse.predictions

        } catch {
            let errorMsg = "Request failed: \(error.localizedDescription)"
            await MainActor.run { lastError = errorMsg }
            logger.error("\(errorMsg, privacy: .public)")
            return []
        }
    }

    // MARK: - Convenience: detect and return DetectionResults

    func detectAsDetectionResults(image: UIImage) async -> [DetectionResult] {
        let predictions = await detect(image: image)
        return predictions.map { $0.toDetectionResult() }
    }

    // MARK: - URL Construction

    private func buildEndpointURL() -> URL? {
        let urlString = "\(baseHost)/\(workspace)/\(project)/\(version)?api_key=\(apiKey)"
        return URL(string: urlString)
    }
}
