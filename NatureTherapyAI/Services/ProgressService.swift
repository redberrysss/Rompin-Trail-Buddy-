import Foundation
import SwiftData

final class ProgressService {
    static let shared = ProgressService()
    
    private init() {}
    
    func getProgress(modelContext: ModelContext) -> ChildProgress? {
        let descriptor = FetchDescriptor<ChildProgress>(
            sortBy: [SortDescriptor(\.lastActiveDate, order: .reverse)]
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    func getAllDiscoveredObjects(modelContext: ModelContext) -> [NatureObject] {
        let descriptor = FetchDescriptor<NatureObject>(
            sortBy: [SortDescriptor(\.dateDiscovered, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func recordActivity(type: ActivityType, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ChildProgress>()
        
        if let progress = try? modelContext.fetch(descriptor).first {
            progress.totalActivitiesCompleted += 1
            progress.lastActiveDate = Date()
            switch type {
            case .breathing:
                progress.breathingExercisesDone += 1
            case .drawing:
                progress.drawingActivitiesDone += 1
            case .observation:
                progress.observationChallengesDone += 1
            }
            updateBadges(for: progress, modelContext: modelContext)
        } else {
            let newProgress = ChildProgress(totalActivitiesCompleted: 1)
            switch type {
            case .breathing:
                newProgress.breathingExercisesDone = 1
            case .drawing:
                newProgress.drawingActivitiesDone = 1
            case .observation:
                newProgress.observationChallengesDone = 1
            }
            modelContext.insert(newProgress)
            updateBadges(for: newProgress, modelContext: modelContext)
        }
    }
    
    func recordExplorationTime(_ seconds: TimeInterval, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ChildProgress>()
        
        if let progress = try? modelContext.fetch(descriptor).first {
            progress.totalExplorationTime += seconds
            progress.lastActiveDate = Date()
            updateBadges(for: progress, modelContext: modelContext)
        } else {
            let newProgress = ChildProgress(totalExplorationTime: seconds)
            modelContext.insert(newProgress)
        }
    }
    
    private func updateBadges(for progress: ChildProgress, modelContext: ModelContext) {
        if progress.uniqueObjectsDiscovered.count >= 1 && !progress.badges.contains("first_discovery") {
            progress.badges.append("first_discovery")
        }
        if progress.uniqueObjectsDiscovered.count >= 5 && !progress.badges.contains("collector_5") {
            progress.badges.append("collector_5")
        }
        if progress.uniqueObjectsDiscovered.count >= 10 && !progress.badges.contains("collector_10") {
            progress.badges.append("collector_10")
        }
        if progress.breathingExercisesDone >= 1 && !progress.badges.contains("breathing_1") {
            progress.badges.append("breathing_1")
        }
        if progress.breathingExercisesDone >= 5 && !progress.badges.contains("breathing_5") {
            progress.badges.append("breathing_5")
        }
        if progress.drawingActivitiesDone >= 1 && !progress.badges.contains("drawing_1") {
            progress.badges.append("drawing_1")
        }
        if progress.observationChallengesDone >= 1 && !progress.badges.contains("observer_1") {
            progress.badges.append("observer_1")
        }
        if progress.totalExplorationTime >= 1800 && !progress.badges.contains("time_30min") {
            progress.badges.append("time_30min")
        }
        if progress.totalExplorationTime >= 7200 && !progress.badges.contains("time_2hr") {
            progress.badges.append("time_2hr")
        }
    }
}

enum ActivityType {
    case breathing, drawing, observation
}
