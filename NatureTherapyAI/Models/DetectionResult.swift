import Foundation
import CoreGraphics

struct DetectionResult: Identifiable {
    let id = UUID()
    let objectName: String
    let confidence: Float
    let boundingBox: CGRect
    
    var confidencePercentage: String {
        "\(Int(confidence * 100))%"
    }
}

struct DetectionFrame {
    let results: [DetectionResult]
    let timestamp: Date
}
