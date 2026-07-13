import Foundation
import SwiftData

@Model
final class ActivitySession {
    var id: UUID
    var participantID: UUID
    var activityNumber: Int
    var startedAt: Date
    var completedAt: Date?
    var isCompleted: Bool
    var progress: Double

    @Relationship(deleteRule: .cascade) var observations: [ObservationRecord]?
    @Relationship(deleteRule: .cascade) var sensoryRecords: [SensoryRecord]?
    @Relationship(deleteRule: .cascade) var treasureRecords: [TreasureRecord]?
    @Relationship(deleteRule: .cascade) var artworks: [ArtworkRecord]?

    init(participantID: UUID, activityNumber: Int) {
        self.id = UUID()
        self.participantID = participantID
        self.activityNumber = activityNumber
        self.startedAt = Date()
        self.isCompleted = false
        self.progress = 0
    }
}
