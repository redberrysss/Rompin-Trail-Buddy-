import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore

final class FirebaseObservationRepository: ObservationRepository {
    private let db = Firestore.firestore()

    private func collection(ownerId: String) -> CollectionReference {
        db.collection("users").document(ownerId).collection("observations")
    }

    func createObservation(_ observation: FSObservation) async throws {
        try collection(ownerId: observation.ownerId).addDocument(from: observation)
    }

    func fetchObservations(ownerId: String, participantId: String) async throws -> [FSObservation] {
        let snapshot = try await collection(ownerId: ownerId)
            .whereField("participantId", isEqualTo: participantId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSObservation.self) }
    }

    func updateObservation(_ observation: FSObservation) async throws {
        guard let id = observation.id else { return }
        try collection(ownerId: observation.ownerId).document(id).setData(from: observation)
    }

    func deleteObservation(id: String) async throws {
        let ownerId = try await ownerIdForObservation(id)
        try await db.collection("users").document(ownerId).collection("observations").document(id).delete()
    }

    private func ownerIdForObservation(_ obsId: String) async throws -> String {
        let groups = try await db.collectionGroup("observations")
            .whereField(FieldPath.documentId(), isEqualTo: obsId)
            .getDocuments()
        guard let doc = groups.documents.first else { throw RepositoryError.notFound }
        return doc.reference.parent.parent!.documentID
    }
}

final class FirebaseSensoryRepository: SensoryRepository {
    private let db = Firestore.firestore()

    private func collection(ownerId: String) -> CollectionReference {
        db.collection("users").document(ownerId).collection("sensoryRecords")
    }

    func createSensoryRecord(_ record: FSSensoryRecord) async throws {
        try collection(ownerId: record.ownerId).addDocument(from: record)
    }

    func fetchSensoryRecords(ownerId: String, participantId: String) async throws -> [FSSensoryRecord] {
        let snapshot = try await collection(ownerId: ownerId)
            .whereField("participantId", isEqualTo: participantId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSSensoryRecord.self) }
    }

    func updateSensoryRecord(_ record: FSSensoryRecord) async throws {
        guard let id = record.id else { return }
        try collection(ownerId: record.ownerId).document(id).setData(from: record)
    }

    func deleteSensoryRecord(id: String) async throws {
        let ownerId = try await ownerIdForSensoryRecord(id)
        try await db.collection("users").document(ownerId).collection("sensoryRecords").document(id).delete()
    }

    private func ownerIdForSensoryRecord(_ recordId: String) async throws -> String {
        let groups = try await db.collectionGroup("sensoryRecords")
            .whereField(FieldPath.documentId(), isEqualTo: recordId)
            .getDocuments()
        guard let doc = groups.documents.first else { throw RepositoryError.notFound }
        return doc.reference.parent.parent!.documentID
    }
}

final class FirebaseTreasureRepository: TreasureRepository {
    private let db = Firestore.firestore()

    private func collection(ownerId: String) -> CollectionReference {
        db.collection("users").document(ownerId).collection("treasureRecords")
    }

    func createTreasureRecord(_ record: FSTreasureRecord) async throws {
        try collection(ownerId: record.ownerId).addDocument(from: record)
    }

    func fetchTreasureRecords(ownerId: String, participantId: String) async throws -> [FSTreasureRecord] {
        let snapshot = try await collection(ownerId: ownerId)
            .whereField("participantId", isEqualTo: participantId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSTreasureRecord.self) }
    }

    func updateTreasureRecord(_ record: FSTreasureRecord) async throws {
        guard let id = record.id else { return }
        try collection(ownerId: record.ownerId).document(id).setData(from: record)
    }

    func deleteTreasureRecord(id: String) async throws {
        let ownerId = try await ownerIdForTreasureRecord(id)
        try await db.collection("users").document(ownerId).collection("treasureRecords").document(id).delete()
    }

    private func ownerIdForTreasureRecord(_ recordId: String) async throws -> String {
        let groups = try await db.collectionGroup("treasureRecords")
            .whereField(FieldPath.documentId(), isEqualTo: recordId)
            .getDocuments()
        guard let doc = groups.documents.first else { throw RepositoryError.notFound }
        return doc.reference.parent.parent!.documentID
    }
}

final class FirebaseArtworkRepository: ArtworkRepository {
    private let db = Firestore.firestore()

    private func collection(ownerId: String) -> CollectionReference {
        db.collection("users").document(ownerId).collection("artworks")
    }

    func createArtwork(_ artwork: FSArtworkRecord) async throws {
        try collection(ownerId: artwork.ownerId).addDocument(from: artwork)
    }

    func fetchArtworks(ownerId: String, participantId: String) async throws -> [FSArtworkRecord] {
        let snapshot = try await collection(ownerId: ownerId)
            .whereField("participantId", isEqualTo: participantId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSArtworkRecord.self) }
    }

    func updateArtwork(_ artwork: FSArtworkRecord) async throws {
        guard let id = artwork.id else { return }
        try collection(ownerId: artwork.ownerId).document(id).setData(from: artwork)
    }

    func deleteArtwork(id: String) async throws {
        let ownerId = try await ownerIdForArtwork(id)
        try await db.collection("users").document(ownerId).collection("artworks").document(id).delete()
    }

    private func ownerIdForArtwork(_ artworkId: String) async throws -> String {
        let groups = try await db.collectionGroup("artworks")
            .whereField(FieldPath.documentId(), isEqualTo: artworkId)
            .getDocuments()
        guard let doc = groups.documents.first else { throw RepositoryError.notFound }
        return doc.reference.parent.parent!.documentID
    }
}
#else
final class FirebaseObservationRepository: ObservationRepository {
    func createObservation(_ observation: FSObservation) async throws { throw RepositoryError.notConfigured }
    func fetchObservations(ownerId: String, participantId: String) async throws -> [FSObservation] { return [] }
    func updateObservation(_ observation: FSObservation) async throws { throw RepositoryError.notConfigured }
    func deleteObservation(id: String) async throws { throw RepositoryError.notConfigured }
}

final class FirebaseSensoryRepository: SensoryRepository {
    func createSensoryRecord(_ record: FSSensoryRecord) async throws { throw RepositoryError.notConfigured }
    func fetchSensoryRecords(ownerId: String, participantId: String) async throws -> [FSSensoryRecord] { return [] }
    func updateSensoryRecord(_ record: FSSensoryRecord) async throws { throw RepositoryError.notConfigured }
    func deleteSensoryRecord(id: String) async throws { throw RepositoryError.notConfigured }
}

final class FirebaseTreasureRepository: TreasureRepository {
    func createTreasureRecord(_ record: FSTreasureRecord) async throws { throw RepositoryError.notConfigured }
    func fetchTreasureRecords(ownerId: String, participantId: String) async throws -> [FSTreasureRecord] { return [] }
    func updateTreasureRecord(_ record: FSTreasureRecord) async throws { throw RepositoryError.notConfigured }
    func deleteTreasureRecord(id: String) async throws { throw RepositoryError.notConfigured }
}

final class FirebaseArtworkRepository: ArtworkRepository {
    func createArtwork(_ artwork: FSArtworkRecord) async throws { throw RepositoryError.notConfigured }
    func fetchArtworks(ownerId: String, participantId: String) async throws -> [FSArtworkRecord] { return [] }
    func updateArtwork(_ artwork: FSArtworkRecord) async throws { throw RepositoryError.notConfigured }
    func deleteArtwork(id: String) async throws { throw RepositoryError.notConfigured }
}
#endif
