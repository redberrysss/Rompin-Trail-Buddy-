import Foundation
import SwiftData

@Model
final class ChildProgress {
    var id: String
    var totalObjectsDiscovered: Int
    var totalActivitiesCompleted: Int
    var totalExplorationTime: TimeInterval
    var breathingExercisesDone: Int
    var drawingActivitiesDone: Int
    var observationChallengesDone: Int
    var badges: [String]
    var lastActiveDate: Date
    
    var uniqueObjectsDiscovered: [String]
    
    init(id: String = UUID().uuidString,
         totalObjectsDiscovered: Int = 0,
         totalActivitiesCompleted: Int = 0,
         totalExplorationTime: TimeInterval = 0,
         breathingExercisesDone: Int = 0,
         drawingActivitiesDone: Int = 0,
         observationChallengesDone: Int = 0,
         badges: [String] = [],
         lastActiveDate: Date = Date(),
         uniqueObjectsDiscovered: [String] = []) {
        self.id = id
        self.totalObjectsDiscovered = totalObjectsDiscovered
        self.totalActivitiesCompleted = totalActivitiesCompleted
        self.totalExplorationTime = totalExplorationTime
        self.breathingExercisesDone = breathingExercisesDone
        self.drawingActivitiesDone = drawingActivitiesDone
        self.observationChallengesDone = observationChallengesDone
        self.badges = badges
        self.lastActiveDate = lastActiveDate
        self.uniqueObjectsDiscovered = uniqueObjectsDiscovered
    }
}

struct Badge: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    
    static let allBadges: [Badge] = [
        Badge(id: "first_discovery", name: "First Discovery", emoji: "🔍",
              description: "Discovered your first nature object!"),
        Badge(id: "collector_5", name: "Nature Collector", emoji: "🌿",
              description: "Discovered 5 different objects!"),
        Badge(id: "collector_10", name: "Expert Explorer", emoji: "🏆",
              description: "Discovered 10 different objects!"),
        Badge(id: "breathing_1", name: "Calm Mind", emoji: "🧘",
              description: "Completed your first breathing exercise!"),
        Badge(id: "breathing_5", name: "Peaceful Soul", emoji: "🕊️",
              description: "Completed 5 breathing exercises!"),
        Badge(id: "drawing_1", name: "Little Artist", emoji: "🎨",
              description: "Created your first nature drawing!"),
        Badge(id: "observer_1", name: "Sharp Eyes", emoji: "👁️",
              description: "Completed your first observation challenge!"),
        Badge(id: "time_30min", name: "Nature Lover", emoji: "⏰",
              description: "Spent 30 minutes exploring nature!"),
        Badge(id: "time_2hr", name: "Dedicated Naturalist", emoji: "🌟",
              description: "Spent 2 hours exploring nature!")
    ]
}
