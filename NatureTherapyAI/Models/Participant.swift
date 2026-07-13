import Foundation
import SwiftData

@Model
final class Participant {
    var id: UUID
    var name: String
    var createdAt: Date
    var avatarName: String?
    var notes: String?

    @Relationship(deleteRule: .cascade) var activitySessions: [ActivitySession]?
    @Relationship(deleteRule: .cascade) var observations: [ObservationRecord]?
    @Relationship(deleteRule: .cascade) var sensoryRecords: [SensoryRecord]?
    @Relationship(deleteRule: .cascade) var treasureRecords: [TreasureRecord]?
    @Relationship(deleteRule: .cascade) var artworks: [ArtworkRecord]?

    init(name: String, avatarName: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.avatarName = avatarName
        self.notes = notes
    }
}
