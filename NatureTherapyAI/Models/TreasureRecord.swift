import Foundation
import SwiftData

@Model
final class TreasureRecord {
    var id: UUID
    var sessionID: UUID
    var participantID: UUID
    var itemName: String
    var imagePath: String?
    var isFound: Bool
    var isSkipped: Bool
    var createdAt: Date

    init(sessionID: UUID, participantID: UUID, itemName: String) {
        self.id = UUID()
        self.sessionID = sessionID
        self.participantID = participantID
        self.itemName = itemName
        self.isFound = false
        self.isSkipped = false
        self.createdAt = Date()
    }
}
