import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct UserProfile: Codable, Identifiable {
    var id: String?
    var fullName: String
    var email: String
    var role: String
    var createdAt: Date
    var updatedAt: Date
}

struct FSParticipant: Codable, Identifiable {
    var id: String?
    var ownerId: String
    var name: String
    var avatarStoragePath: String?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
}

struct FSSession: Codable, Identifiable {
    var id: String?
    var ownerId: String
    var participantId: String
    var activityNumber: Int
    var startedAt: Date
    var completedAt: Date?
    var isCompleted: Bool
    var isSkipped: Bool
    var progress: Double
    var createdAt: Date
    var updatedAt: Date
}

struct FSObservation: Codable, Identifiable {
    var id: String?
    var ownerId: String
    var participantId: String
    var sessionId: String
    var activityNumber: Int
    var category: String
    var objectName: String
    var detectedLabel: String?
    var confidence: Double?
    var ocrText: String?
    var imageStoragePath: String?
    var imageDownloadURL: String?
    var notes: String?
    var isConfirmed: Bool
    var isSkipped: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct FSSensoryRecord: Codable, Identifiable {
    var id: String?
    var ownerId: String
    var participantId: String
    var sessionId: String
    var stationNumber: Int
    var senseType: String
    var selectedValue: String
    var emotion: String?
    var imageStoragePath: String?
    var imageDownloadURL: String?
    var audioStoragePath: String?
    var audioDownloadURL: String?
    var isSkipped: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct FSTreasureRecord: Codable, Identifiable {
    var id: String?
    var ownerId: String
    var participantId: String
    var sessionId: String
    var itemName: String
    var imageStoragePath: String?
    var imageDownloadURL: String?
    var isFound: Bool
    var isSkipped: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct FSArtworkRecord: Codable, Identifiable {
    var id: String?
    var ownerId: String
    var participantId: String
    var sessionId: String
    var title: String
    var artworkStoragePath: String
    var artworkDownloadURL: String?
    var sourceImageIds: [String]
    var artworkType: String
    var createdAt: Date
    var updatedAt: Date
}

struct PendingUpload: Codable, Identifiable {
    var id: String?
    var ownerId: String
    var participantId: String
    var activityNumber: Int
    var localFilePath: String
    var storageDestinationPath: String
    var recordType: String
    var recordPayload: String
    var retryCount: Int
    var createdAt: Date
}
