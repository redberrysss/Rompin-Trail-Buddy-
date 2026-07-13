import SwiftData
import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore

final class DataMigrationService {
    static let shared = DataMigrationService()
    private let db = Firestore.firestore()

    private init() {}

    func hasLocalData(context: ModelContext) -> Bool {
        let participantCount = (try? context.fetch(FetchDescriptor<Participant>()))?.count ?? 0
        let sessionCount = (try? context.fetch(FetchDescriptor<ActivitySession>()))?.count ?? 0
        return participantCount > 0 || sessionCount > 0
    }

    func migrateAll(ownerId: String, context: ModelContext, progress: (Double, String) -> Void) async throws {
        let participants = try context.fetch(FetchDescriptor<Participant>())
        let total = Double(participants.count + 1)
        var completed = 0.0

        for participant in participants {
            progress(completed / total, "Memindahkan peserta: \(participant.name)")
            try await migrateParticipant(participant, ownerId: ownerId, context: context)
            completed += 1
        }

        progress(1.0, "Migrasi selesai!")
    }

    private func migrateParticipant(_ participant: Participant, ownerId: String, context: ModelContext) async throws {
        let fsParticipant: [String: Any] = [
            "ownerId": ownerId,
            "name": participant.name,
            "createdAt": Timestamp(date: participant.createdAt),
            "updatedAt": Timestamp(date: Date())
        ]
        _ = try await db.collection("users").document(ownerId).collection("participants")
            .addDocument(data: fsParticipant)

        let participantId = participant.id.uuidString
        try await migrateSessions(participantId: participantId, ownerId: ownerId, context: context)
        try await migrateObservations(participantId: participantId, ownerId: ownerId, context: context)
        try await migrateSensoryRecords(participantId: participantId, ownerId: ownerId, context: context)
        try await migrateTreasureRecords(participantId: participantId, ownerId: ownerId, context: context)
        try await migrateArtworks(participantId: participantId, ownerId: ownerId, context: context)
    }

    private func migrateSessions(participantId: String, ownerId: String, context: ModelContext) async throws {
        let sessions = try context.fetch(FetchDescriptor<ActivitySession>())
        for session in sessions {
            let data: [String: Any] = [
                "ownerId": ownerId,
                "participantId": participantId,
                "activityNumber": session.activityNumber,
                "startedAt": Timestamp(date: session.startedAt),
                "completedAt": session.completedAt.map { Timestamp(date: $0) } as Any,
                "isCompleted": session.isCompleted,
                "isSkipped": session.isSkipped,
                "progress": session.progress,
                "createdAt": Timestamp(date: session.createdAt),
                "updatedAt": Timestamp(date: Date())
            ]
            _ = try await db.collection("users").document(ownerId).collection("activitySessions").addDocument(data: data)
        }
    }

    private func migrateObservations(participantId: String, ownerId: String, context: ModelContext) async throws {
        let obs = try context.fetch(FetchDescriptor<ObservationRecord>())
        for record in obs {
            let data: [String: Any] = [
                "ownerId": ownerId,
                "participantId": participantId,
                "sessionId": record.sessionId?.uuidString ?? "",
                "activityNumber": 1,
                "category": record.category ?? "",
                "objectName": record.objectName ?? "",
                "detectedLabel": record.detectedLabel as Any,
                "confidence": record.confidence as Any,
                "ocrText": record.ocrText as Any,
                "notes": record.notes as Any,
                "isConfirmed": record.isConfirmed,
                "isSkipped": record.isSkipped,
                "createdAt": Timestamp(date: record.createdAt),
                "updatedAt": Timestamp(date: Date())
            ]
            _ = try await db.collection("users").document(ownerId).collection("observations").addDocument(data: data)
        }
    }

    private func migrateSensoryRecords(participantId: String, ownerId: String, context: ModelContext) async throws {
        let records = try context.fetch(FetchDescriptor<SensoryRecord>())
        for record in records {
            let data: [String: Any] = [
                "ownerId": ownerId,
                "participantId": participantId,
                "sessionId": record.sessionId?.uuidString ?? "",
                "stationNumber": record.stationNumber,
                "senseType": record.senseType,
                "selectedValue": record.selectedValue,
                "emotion": record.emotion as Any,
                "isSkipped": record.isSkipped,
                "createdAt": Timestamp(date: record.createdAt),
                "updatedAt": Timestamp(date: Date())
            ]
            _ = try await db.collection("users").document(ownerId).collection("sensoryRecords").addDocument(data: data)
        }
    }

    private func migrateTreasureRecords(participantId: String, ownerId: String, context: ModelContext) async throws {
        let records = try context.fetch(FetchDescriptor<TreasureRecord>())
        for record in records {
            let data: [String: Any] = [
                "ownerId": ownerId,
                "participantId": participantId,
                "sessionId": record.sessionId?.uuidString ?? "",
                "itemName": record.itemName,
                "isFound": record.isFound,
                "isSkipped": record.isSkipped,
                "createdAt": Timestamp(date: record.createdAt),
                "updatedAt": Timestamp(date: Date())
            ]
            _ = try await db.collection("users").document(ownerId).collection("treasureRecords").addDocument(data: data)
        }
    }

    private func migrateArtworks(participantId: String, ownerId: String, context: ModelContext) async throws {
        let artworks = try context.fetch(FetchDescriptor<ArtworkRecord>())
        for artwork in artworks {
            let data: [String: Any] = [
                "ownerId": ownerId,
                "participantId": participantId,
                "sessionId": artwork.sessionId?.uuidString ?? "",
                "title": artwork.title,
                "artworkType": artwork.artworkType,
                "sourceImageIds": [],
                "createdAt": Timestamp(date: artwork.createdAt),
                "updatedAt": Timestamp(date: Date())
            ]
            _ = try await db.collection("users").document(ownerId).collection("artworks").addDocument(data: data)
        }
    }
}
#else
final class DataMigrationService {
    static let shared = DataMigrationService()
    private init() {}

    func hasLocalData(context: ModelContext) -> Bool { false }
    func migrateAll(ownerId: String, context: ModelContext, progress: (Double, String) -> Void) async throws {
        throw RepositoryError.notConfigured
    }
}
#endif
