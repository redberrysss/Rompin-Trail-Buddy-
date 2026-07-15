import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore

final class FirebaseParticipantRepository: ParticipantRepository {
    private let db = Firestore.firestore()

    private func collection(ownerId: String) -> CollectionReference {
        db.collection("users").document(ownerId).collection("participants")
    }

    func createParticipant(_ participant: FSParticipant) async throws {
        var data = participant
        try collection(ownerId: participant.ownerId).addDocument(from: data)
    }

    func fetchParticipants(ownerId: String) async throws -> [FSParticipant] {
        let snapshot = try await collection(ownerId: ownerId)
            .order(by: "createdAt", descending: false)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSParticipant.self) }
    }

    func updateParticipant(_ participant: FSParticipant) async throws {
        guard let id = participant.id else { return }
        var data = participant
        try collection(ownerId: participant.ownerId).document(id).setData(from: data)
    }

    func deleteParticipant(id: String) async throws {
        let ownerId = try await ownerIdForParticipant(id)
        try await collection(ownerId: ownerId).document(id).delete()
    }

    private func ownerIdForParticipant(_ participantId: String) async throws -> String {
        let snapshot = try await db.collectionGroup("participants")
            .whereField(FieldPath.documentID(), isEqualTo: participantId)
            .getDocuments()
        guard let doc = snapshot.documents.first else {
            throw RepositoryError.notFound
        }
        return doc.reference.parent.parent!.documentID
    }
}
#else
final class FirebaseParticipantRepository: ParticipantRepository {
    func createParticipant(_ participant: FSParticipant) async throws {
        throw RepositoryError.notConfigured
    }
    func fetchParticipants(ownerId: String) async throws -> [FSParticipant] { return [] }
    func updateParticipant(_ participant: FSParticipant) async throws {
        throw RepositoryError.notConfigured
    }
    func deleteParticipant(id: String) async throws {
        throw RepositoryError.notConfigured
    }
}
#endif
