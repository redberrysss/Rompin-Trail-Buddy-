import Foundation
import SwiftData

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var progress: ChildProgress?
    @Published var discoveredObjects: [NatureObject] = []
    @Published var earnedBadges: [Badge] = []
    
    private var modelContext: ModelContext?
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }
    
    func refresh() {
        guard let context = modelContext else { return }
        progress = ProgressService.shared.getProgress(modelContext: context)
        discoveredObjects = ProgressService.shared.getAllDiscoveredObjects(modelContext: context)
        earnedBadges = Badge.allBadges.filter { progress?.badges.contains($0.id) ?? false }
    }
    
    var formattedTime: String {
        guard let time = progress?.totalExplorationTime else { return "0 min" }
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
    
    var completedActivities: Int {
        progress?.totalActivitiesCompleted ?? 0
    }
    
    var objectsDiscoveredCount: Int {
        progress?.uniqueObjectsDiscovered.count ?? 0
    }
}
