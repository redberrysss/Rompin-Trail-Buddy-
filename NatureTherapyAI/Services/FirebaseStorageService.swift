import UIKit

#if canImport(FirebaseStorage)
import FirebaseStorage

final class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    private let storage = Storage.storage()

    private init() {}

    func uploadImage(image: UIImage, userId: String, participantId: String, activityNumber: Int, imageId: String) async throws -> (storagePath: String, downloadURL: String) {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            throw StorageError.compressionFailed
        }

        let activityFolder: String
        switch activityNumber {
        case 1: activityFolder = "observations"
        case 2: activityFolder = "sensory"
        case 3: activityFolder = "treasure"
        case 4: activityFolder = "artworks"
        default: activityFolder = "observations"
        }

        let path = "users/\(userId)/participants/\(participantId)/\(activityFolder)/\(imageId).jpg"
        let ref = storage.reference().child(path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()

        return (path, url.absoluteString)
    }

    func uploadAudio(data: Data, userId: String, participantId: String, audioId: String) async throws -> (storagePath: String, downloadURL: String) {
        let path = "users/\(userId)/participants/\(participantId)/audio/\(audioId).m4a"
        let ref = storage.reference().child(path)

        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()

        return (path, url.absoluteString)
    }

    func deleteFile(at path: String) async throws {
        try await storage.reference().child(path).delete()
    }

    func downloadURL(for path: String) async throws -> URL {
        try await storage.reference().child(path).downloadURL()
    }
}

enum StorageError: LocalizedError {
    case compressionFailed
    case uploadFailed
    case deleteFailed
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .compressionFailed: return "Gagal memampatkan gambar."
        case .uploadFailed: return "Gagal memuat naik ke awan."
        case .deleteFailed: return "Gagal memadam fail."
        case .notConfigured: return "Firebase Storage belum dikonfigurasikan."
        }
    }
}
#else
final class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    private init() {}

    func uploadImage(image: UIImage, userId: String, participantId: String, activityNumber: Int, imageId: String) async throws -> (storagePath: String, downloadURL: String) {
        throw StorageError.notConfigured
    }

    func uploadAudio(data: Data, userId: String, participantId: String, audioId: String) async throws -> (storagePath: String, downloadURL: String) {
        throw StorageError.notConfigured
    }

    func deleteFile(at path: String) async throws {
        throw StorageError.notConfigured
    }

    func downloadURL(for path: String) async throws -> URL {
        throw StorageError.notConfigured
    }
}

enum StorageError: LocalizedError {
    case compressionFailed
    case uploadFailed
    case deleteFailed
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .compressionFailed: return "Gagal memampatkan gambar."
        case .uploadFailed: return "Gagal memuat naik ke awan."
        case .deleteFailed: return "Gagal memadam fail."
        case .notConfigured: return "Firebase Storage belum dikonfigurasikan."
        }
    }
}
#endif
