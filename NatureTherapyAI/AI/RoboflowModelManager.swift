import Foundation
import CoreML
import Vision
import OSLog

struct RoboflowConfig {
    var workspace: String
    var project: String
    var version: Int
    var apiKey: String

    static let `default` = RoboflowConfig(
        workspace: "your-workspace",
        project: "nature-therapy-ai",
        version: 1,
        apiKey: "your-roboflow-api-key"
    )

    var modelFileName: String {
        "NatureDetection"
    }

    var roboflowExportURL: String {
        "https://universe.roboflow.com/\(workspace)/\(project)/\(version)"
    }
}

enum RoboflowModelError: LocalizedError {
    case modelNotFound
    case modelLoadingFailed(String)
    case invalidModel

    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "NatureDetection.mlmodel not found. Train and export from Roboflow, then add to Xcode project."
        case .modelLoadingFailed(let reason):
            return "Failed to load model: \(reason)"
        case .invalidModel:
            return "The Core ML model is invalid or incompatible with iOS 17+."
        }
    }
}

final class RoboflowModelManager {
    static let shared = RoboflowModelManager()

    var config: RoboflowConfig
    private var model: VNCoreMLModel?
    private let logger = Logger(subsystem: "com.naturetherapy.ai", category: "RoboflowModelManager")

    private init() {
        self.config = .default
    }

    var isModelLoaded: Bool {
        model != nil
    }

    func configure(with config: RoboflowConfig) {
        self.config = config
    }

    func loadModel() throws -> VNCoreMLModel {
        if let existing = model {
            logger.info("Returning cached model")
            return existing
        }

        guard let mlModelURL = Bundle.main.url(forResource: config.modelFileName,
                                                withExtension: "mlmodelc") ??
                               Bundle.main.url(forResource: config.modelFileName,
                                                withExtension: "mlmodel")
        else {
            logger.error("Model file not found: \(self.config.modelFileName)")
            throw RoboflowModelError.modelNotFound
        }

        logger.info("Found model at: \(mlModelURL.lastPathComponent)")

        let compiledURL: URL
        if mlModelURL.pathExtension == "mlmodel" {
            compiledURL = try MLModel.compileModel(at: mlModelURL)
            logger.info("Model compiled at: \(compiledURL.lastPathComponent)")
        } else {
            compiledURL = mlModelURL
        }

        let mlModel = try MLModel(contentsOf: compiledURL)
        logger.info("MLModel loaded successfully")

        guard let visionModel = try? VNCoreMLModel(for: mlModel) else {
            logger.error("Failed to create VNCoreMLModel")
            throw RoboflowModelError.invalidModel
        }

        self.model = visionModel
        logger.info("VNCoreMLModel created successfully")
        return visionModel
    }

    func unloadModel() {
        model = nil
        logger.info("Model unloaded")
    }

    var modelStatusDescription: String {
        if isModelLoaded {
            return "Model loaded (v\(config.version))"
        }
        return "No model loaded. Train at: \(config.roboflowExportURL)"
    }
}
