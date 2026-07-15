import Foundation

#if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
import FirebaseAuth
import FirebaseFirestore

final class AuthenticationService {
    static let shared = AuthenticationService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    private init() {}

    var currentUser: User? { auth.currentUser }
    var isSignedIn: Bool { auth.currentUser != nil }

    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user
    }

    func register(fullName: String, email: String, password: String, role: String = "participant") async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        let user = result.user

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = fullName
        try await changeRequest.commitChanges()

        let userDoc: [String: Any] = [
            "fullName": fullName,
            "email": email,
            "role": role,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        try await db.collection("users").document(user.uid).setData(userDoc)

        return user
    }

    func fetchUserRole(uid: String) async throws -> String? {
        let doc = try await db.collection("users").document(uid).getDocument()
        return doc.data()?["role"] as? String
    }

    func signOut() throws { try auth.signOut() }

    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func deleteAccount() async throws {
        guard let user = auth.currentUser else { return }
        let uid = user.uid
        try await deleteUserData(uid: uid)
        try await user.delete()
    }

    private func deleteUserData(uid: String) async throws {
        let subcollections = [
            "participants", "activitySessions", "observations",
            "sensoryRecords", "treasureRecords", "artworks"
        ]
        for sub in subcollections {
            let snapshot = try await db.collection("users").document(uid).collection(sub).getDocuments()
            for doc in snapshot.documents {
                try await doc.reference.delete()
            }
        }
        try await db.collection("users").document(uid).delete()
    }

    func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue: return "Alamat e-mel tidak sah."
        case AuthErrorCode.wrongPassword.rawValue: return "Kata laluan tidak betul."
        case AuthErrorCode.userNotFound.rawValue: return "Akaun tidak dijumpai."
        case AuthErrorCode.emailAlreadyInUse.rawValue: return "Alamat e-mel ini telah didaftarkan."
        case AuthErrorCode.weakPassword.rawValue: return "Kata laluan terlalu lemah."
        case AuthErrorCode.networkError.rawValue: return "Sambungan internet tidak tersedia."
        default: return "Tidak berjaya. Sila cuba lagi."
        }
    }
}
#else
final class AuthenticationService {
    static let shared = AuthenticationService()
    private init() {}

    var isSignedIn: Bool { false }
    var currentUserID: String? { nil }
    var currentUserName: String? { nil }
    var currentUserEmail: String? { nil }

    func signIn(email: String, password: String) async throws -> Never {
        throw AuthError.notConfigured
    }

    func register(fullName: String, email: String, password: String, role: String = "participant") async throws -> Never {
        throw AuthError.notConfigured
    }

    func fetchUserRole(uid: String) async throws -> String? { return nil }

    func signOut() throws {
        throw AuthError.notConfigured
    }

    func resetPassword(email: String) async throws {
        throw AuthError.notConfigured
    }

    func deleteAccount() async throws {
        throw AuthError.notConfigured
    }

    func mapFirebaseError(_ error: Error) -> String {
        "Firebase belum dikonfigurasikan."
    }
}

enum AuthError: LocalizedError {
    case notConfigured
    var errorDescription: String? {
        "Firebase belum dikonfigurasikan. Sila tambah GoogleService-Info.plist."
    }
}
#endif
