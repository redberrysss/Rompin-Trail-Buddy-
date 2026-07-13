import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore

final class FirebaseSessionRepository: SessionRepository {
    private let db = Firestore.firestore()

    private func collection(ownerId: String) -> CollectionReference {
        db.collection("users").document(ownerId).collection("activitySessions")
    }

    func createSession(_ session: FSSession) async throws {
        try collection(ownerId: session.ownerId).addDocument(from: session)
    }

    func fetchSessions(ownerId: String, participantId: String) async throws -> [FSSession] {
        let snapshot = try await collection(ownerId: ownerId)
            .whereField("participantId", isEqualTo: participantId)
            .order(by: "startedAt", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FSSession.self) }
    }

    func updateSession(_ session: FSSession) async throws {
        guard let id = session.id else { return }
        try collection(ownerId: session.ownerId).document(id).setData(from: session)
    }

    func deleteSession(id: String) async throws {
        let ownerId = try await ownerIdForSession(id)
        try await db.collection("users").document(ownerId).collection("activitySessions").document(id).delete()
    }

    private func ownerIdForSession(_ sessionId: String) async throws -> String {
        let groups = try await db.collectionGroup("activitySessions")
            .whereField(FieldPath.documentId(), isEqualTo: sessionId)
            .getDocuments()
        guard let doc = groups.documents.first else { throw RepositoryError.notFound }
        return doc.reference.parent.parent!.documentID
    }
}
#else
final class FirebaseSessionRepository: SessionRepository {
    func createSession(_ session: FSSession) async throws { throw RepositoryError.notConfigured }
    func fetchSessions(ownerId: String, participantId: String) async throws -> [FSSession] { return [] }
    func updateSession(_ session: FSSession) async throws { throw RepositoryError.notConfigured }
    func deleteSession(id: String) async throws { throw RepositoryError.notConfigured }
}
#endif
