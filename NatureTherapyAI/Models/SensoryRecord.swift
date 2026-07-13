import Foundation
import SwiftData

@Model
final class SensoryRecord {
    var id: UUID
    var sessionID: UUID
    var participantID: UUID
    var stationNumber: Int
    var senseType: String
    var selectedValue: String
    var emotion: String?
    var imagePath: String?
    var audioPath: String?
    var isSkipped: Bool
    var createdAt: Date

    init(sessionID: UUID, participantID: UUID, stationNumber: Int, senseType: String, selectedValue: String) {
        self.id = UUID()
        self.sessionID = sessionID
        self.participantID = participantID
        self.stationNumber = stationNumber
        self.senseType = senseType
        self.selectedValue = selectedValue
        self.isSkipped = false
        self.createdAt = Date()
    }
}
