import Foundation
import SwiftData

@Model
final class ArtworkRecord {
    var id: UUID
    var participantID: UUID
    var sessionID: UUID
    var title: String
    var artworkImagePath: String
    var sourceImageIDs: [String]
    var artworkType: String
    var createdAt: Date

    init(participantID: UUID, sessionID: UUID, title: String, artworkImagePath: String, sourceImageIDs: [String], artworkType: String) {
        self.id = UUID()
        self.participantID = participantID
        self.sessionID = sessionID
        self.title = title
        self.artworkImagePath = artworkImagePath
        self.sourceImageIDs = sourceImageIDs
        self.artworkType = artworkType
        self.createdAt = Date()
    }
}
