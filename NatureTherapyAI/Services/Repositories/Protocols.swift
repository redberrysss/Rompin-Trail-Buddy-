import Foundation

protocol ParticipantRepository {
    func createParticipant(_ participant: FSParticipant) async throws
    func fetchParticipants(ownerId: String) async throws -> [FSParticipant]
    func updateParticipant(_ participant: FSParticipant) async throws
    func deleteParticipant(id: String) async throws
}

protocol SessionRepository {
    func createSession(_ session: FSSession) async throws
    func fetchSessions(ownerId: String, participantId: String) async throws -> [FSSession]
    func updateSession(_ session: FSSession) async throws
    func deleteSession(id: String) async throws
}

protocol ObservationRepository {
    func createObservation(_ observation: FSObservation) async throws
    func fetchObservations(ownerId: String, participantId: String) async throws -> [FSObservation]
    func updateObservation(_ observation: FSObservation) async throws
    func deleteObservation(id: String) async throws
}

protocol SensoryRepository {
    func createSensoryRecord(_ record: FSSensoryRecord) async throws
    func fetchSensoryRecords(ownerId: String, participantId: String) async throws -> [FSSensoryRecord]
    func updateSensoryRecord(_ record: FSSensoryRecord) async throws
    func deleteSensoryRecord(id: String) async throws
}

protocol TreasureRepository {
    func createTreasureRecord(_ record: FSTreasureRecord) async throws
    func fetchTreasureRecords(ownerId: String, participantId: String) async throws -> [FSTreasureRecord]
    func updateTreasureRecord(_ record: FSTreasureRecord) async throws
    func deleteTreasureRecord(id: String) async throws
}

protocol ArtworkRepository {
    func createArtwork(_ artwork: FSArtworkRecord) async throws
    func fetchArtworks(ownerId: String, participantId: String) async throws -> [FSArtworkRecord]
    func updateArtwork(_ artwork: FSArtworkRecord) async throws
    func deleteArtwork(id: String) async throws
}

enum RepositoryError: LocalizedError {
    case notFound
    case encodingFailed
    case uploadFailed
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .notFound: return "Rekod tidak dijumpai."
        case .encodingFailed: return "Gagal memproses data."
        case .uploadFailed: return "Gagal memuat naik."
        case .notConfigured: return "Firebase belum dikonfigurasikan."
        }
    }
}
