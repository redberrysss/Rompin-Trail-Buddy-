import CoreML
import Vision

final class ModelHandler {
    static let shared = ModelHandler()

    private init() {}

    var isModelLoaded: Bool {
        RoboflowModelManager.shared.isModelLoaded
    }

    func loadModel() throws -> VNCoreMLModel {
        try RoboflowModelManager.shared.loadModel()
    }

    func unloadModel() {
        RoboflowModelManager.shared.unloadModel()
    }
}
