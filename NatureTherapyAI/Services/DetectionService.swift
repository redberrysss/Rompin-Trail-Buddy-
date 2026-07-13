import Foundation
import SwiftData

final class DetectionService {
    static let shared = DetectionService()
    
    private init() {}
    
    func processDetections(_ results: [DetectionResult],
                           modelContext: ModelContext) {
        for result in results where result.confidence > 0.3 {
            let existing = findObject(named: result.objectName, modelContext: modelContext)
            
            if let existing {
                existing.timesSeen += 1
            } else {
                let sampleInfo = NatureObject.sample(for: result.objectName)
                let natureObject = NatureObject(
                    name: result.objectName,
                    emoji: sampleInfo?.emoji ?? "🌱",
                    objectDescription: sampleInfo?.objectDescription ?? "A wonderful part of nature.",
                    funFact: sampleInfo?.funFact ?? "Every part of nature has a special role.",
                    educationalInfo: sampleInfo?.educationalInfo ?? "Observe its colors and textures.",
                    category: sampleInfo?.category ?? "General"
                )
                modelContext.insert(natureObject)
            }
            
            updateProgress(result.objectName, modelContext: modelContext)
        }
    }
    
    private func findObject(named name: String, modelContext: ModelContext) -> NatureObject? {
        let descriptor = FetchDescriptor<NatureObject>()
        guard let allObjects = try? modelContext.fetch(descriptor) else { return nil }
        return allObjects.first { $0.name == name }
    }
    
    private func updateProgress(_ objectName: String, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ChildProgress>()
        
        if let progress = try? modelContext.fetch(descriptor).first {
            progress.totalObjectsDiscovered += 1
            if !progress.uniqueObjectsDiscovered.contains(objectName) {
                progress.uniqueObjectsDiscovered.append(objectName)
            }
            progress.lastActiveDate = Date()
        } else {
            let newProgress = ChildProgress(
                totalObjectsDiscovered: 1,
                uniqueObjectsDiscovered: [objectName]
            )
            modelContext.insert(newProgress)
        }
    }
}
