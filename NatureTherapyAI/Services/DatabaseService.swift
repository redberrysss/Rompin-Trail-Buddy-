import Foundation
import SwiftData
import OSLog

final class DatabaseService {
    static let shared = DatabaseService()
    private let logger = Logger(subsystem: "com.rompinforest.data", category: "DatabaseService")

    private init() {}

    // MARK: - Participant

    func createParticipant(name: String, avatarName: String? = nil, context: ModelContext) -> Participant {
        let participant = Participant(name: name, avatarName: avatarName)
        context.insert(participant)
        try? context.save()
        logger.info("Participant created: \(name)")
        return participant
    }

    func fetchParticipants(context: ModelContext) -> [Participant] {
        let descriptor = FetchDescriptor<Participant>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func deleteParticipant(_ participant: Participant, context: ModelContext) {
        context.delete(participant)
        try? context.save()
        logger.info("Participant deleted: \(participant.name)")
    }

    // MARK: - ActivitySession

    func createSession(participantID: UUID, activityNumber: Int, context: ModelContext) -> ActivitySession {
        let session = ActivitySession(participantID: participantID, activityNumber: activityNumber)
        context.insert(session)
        try? context.save()
        return session
    }

    func fetchActiveSession(participantID: UUID, activityNumber: Int, context: ModelContext) -> ActivitySession? {
        let descriptor = FetchDescriptor<ActivitySession>(
            predicate: #Predicate { $0.participantID == participantID && $0.activityNumber == activityNumber && !$0.isCompleted },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return try? context.fetch(descriptor).first
    }

    func completeSession(_ session: ActivitySession, context: ModelContext) {
        session.isCompleted = true
        session.completedAt = Date()
        session.progress = 1.0
        try? context.save()
        logger.info("Session completed: activity \(session.activityNumber)")
    }

    func updateProgress(_ session: ActivitySession, progress: Double, context: ModelContext) {
        session.progress = progress
        try? context.save()
    }

    func fetchAllSessions(participantID: UUID, context: ModelContext) -> [ActivitySession] {
        let descriptor = FetchDescriptor<ActivitySession>(
            predicate: #Predicate { $0.participantID == participantID },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - ObservationRecord

    func saveObservation(
        sessionID: UUID, participantID: UUID, activityNumber: Int,
        category: String, objectName: String,
        detectedLabel: String? = nil, confidence: Double? = nil,
        ocrText: String? = nil, imagePath: String? = nil,
        notes: String? = nil, isConfirmed: Bool = false,
        isSkipped: Bool = false, context: ModelContext
    ) -> ObservationRecord {
        let record = ObservationRecord(
            sessionID: sessionID, participantID: participantID,
            activityNumber: activityNumber, category: category, objectName: objectName
        )
        record.detectedLabel = detectedLabel
        record.confidence = confidence
        record.ocrText = ocrText
        record.imagePath = imagePath
        record.notes = notes
        record.isConfirmed = isConfirmed
        record.isSkipped = isSkipped
        context.insert(record)
        try? context.save()
        return record
    }

    func fetchObservations(sessionID: UUID, context: ModelContext) -> [ObservationRecord] {
        let descriptor = FetchDescriptor<ObservationRecord>(
            predicate: #Predicate { $0.sessionID == sessionID },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchAllObservations(participantID: UUID, context: ModelContext) -> [ObservationRecord] {
        let descriptor = FetchDescriptor<ObservationRecord>(
            predicate: #Predicate { $0.participantID == participantID },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func updateObservation(recordID: UUID, isConfirmed: Bool, context: ModelContext) {
        let descriptor = FetchDescriptor<ObservationRecord>(
            predicate: #Predicate { $0.id == recordID }
        )
        if let record = try? context.fetch(descriptor).first {
            record.isConfirmed = isConfirmed
            try? context.save()
        }
    }

    // MARK: - SensoryRecord

    func saveSensoryRecord(
        sessionID: UUID, participantID: UUID, stationNumber: Int,
        senseType: String, selectedValue: String,
        emotion: String? = nil, imagePath: String? = nil,
        audioPath: String? = nil, isSkipped: Bool = false,
        context: ModelContext
    ) -> SensoryRecord {
        let record = SensoryRecord(
            sessionID: sessionID, participantID: participantID,
            stationNumber: stationNumber, senseType: senseType,
            selectedValue: selectedValue
        )
        record.emotion = emotion
        record.imagePath = imagePath
        record.audioPath = audioPath
        record.isSkipped = isSkipped
        context.insert(record)
        try? context.save()
        return record
    }

    func fetchSensoryRecords(sessionID: UUID, context: ModelContext) -> [SensoryRecord] {
        let descriptor = FetchDescriptor<SensoryRecord>(
            predicate: #Predicate { $0.sessionID == sessionID },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - TreasureRecord

    func saveTreasureRecord(
        sessionID: UUID, participantID: UUID, itemName: String,
        imagePath: String? = nil, isFound: Bool = false,
        isSkipped: Bool = false, context: ModelContext
    ) -> TreasureRecord {
        let record = TreasureRecord(sessionID: sessionID, participantID: participantID, itemName: itemName)
        record.imagePath = imagePath
        record.isFound = isFound
        record.isSkipped = isSkipped
        context.insert(record)
        try? context.save()
        return record
    }

    func fetchTreasureRecords(sessionID: UUID, context: ModelContext) -> [TreasureRecord] {
        let descriptor = FetchDescriptor<TreasureRecord>(
            predicate: #Predicate { $0.sessionID == sessionID },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func markTreasureFound(recordID: UUID, imagePath: String, context: ModelContext) {
        let descriptor = FetchDescriptor<TreasureRecord>(
            predicate: #Predicate { $0.id == recordID }
        )
        if let record = try? context.fetch(descriptor).first {
            record.isFound = true
            record.imagePath = imagePath
            try? context.save()
        }
    }

    // MARK: - ArtworkRecord

    func saveArtwork(
        participantID: UUID, sessionID: UUID, title: String,
        artworkImagePath: String, sourceImageIDs: [String],
        artworkType: String, context: ModelContext
    ) -> ArtworkRecord {
        let record = ArtworkRecord(
            participantID: participantID, sessionID: sessionID,
            title: title, artworkImagePath: artworkImagePath,
            sourceImageIDs: sourceImageIDs, artworkType: artworkType
        )
        context.insert(record)
        try? context.save()
        return record
    }

    func fetchArtworks(participantID: UUID, context: ModelContext) -> [ArtworkRecord] {
        let descriptor = FetchDescriptor<ArtworkRecord>(
            predicate: #Predicate { $0.participantID == participantID },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchAllPhotos(participantID: UUID, context: ModelContext) -> [(imagePath: String, objectName: String, date: Date, activityNumber: Int)] {
        let obs = fetchAllObservations(participantID: participantID, context: context)
            .filter { $0.imagePath != nil }
            .map { ($0.imagePath!, $0.objectName, $0.createdAt, $0.activityNumber) }

        let sensory = fetchSensoryRecords(
            sessionID: UUID(), context: context
        ).filter { $0.imagePath != nil }
        .map { ($0.imagePath!, $0.senseType, $0.createdAt, 2) }

        let treasures: [(String, String, Date, Int)] = []
        return obs + sensory + treasures
    }

    // MARK: - Progress

    func getActivityProgress(participantID: UUID, context: ModelContext) -> [Int: Double] {
        let sessions = fetchAllSessions(participantID: participantID, context: context)
        var progress: [Int: Double] = [1: 0, 2: 0, 3: 0, 4: 0]
        for session in sessions {
            progress[session.activityNumber] = max(progress[session.activityNumber] ?? 0, session.progress)
        }
        return progress
    }
}
