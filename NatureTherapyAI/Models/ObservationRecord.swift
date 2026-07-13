import Foundation
import SwiftData

@Model
final class ObservationRecord {
    var id: UUID
    var sessionID: UUID
    var participantID: UUID
    var activityNumber: Int
    var category: String
    var objectName: String
    var detectedLabel: String?
    var confidence: Double?
    var ocrText: String?
    var imagePath: String?
    var audioPath: String?
    var notes: String?
    var isConfirmed: Bool
    var isSkipped: Bool
    var createdAt: Date

    init(sessionID: UUID, participantID: UUID, activityNumber: Int, category: String, objectName: String) {
        self.id = UUID()
        self.sessionID = sessionID
        self.participantID = participantID
        self.activityNumber = activityNumber
        self.category = category
        self.objectName = objectName
        self.isConfirmed = false
        self.isSkipped = false
        self.createdAt = Date()
    }
}
