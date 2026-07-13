import UIKit
import OSLog

final class ImageStorageService {
    static let shared = ImageStorageService()
    private let logger = Logger(subsystem: "com.rompinforest.storage", category: "ImageStorage")

    private let photosDir = "RompinForestExplorer/Photos"
    private let artworkDir = "RompinForestExplorer/Artwork"
    private let audioDir = "RompinForestExplorer/Audio"

    private var photosURL: URL {
        supportDir.appendingPathComponent(photosDir)
    }

    private var artworkURL: URL {
        supportDir.appendingPathComponent(artworkDir)
    }

    private var audioURL: URL {
        supportDir.appendingPathComponent(audioDir)
    }

    private var supportDir: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }

    private init() {
        createDirectories()
    }

    private func createDirectories() {
        for dir in [photosURL, artworkURL, audioURL] {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    func savePhoto(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = photosURL.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            logger.info("Photo saved: \(fileName)")
            return "\(photosDir)/\(fileName)"
        } catch {
            logger.error("Failed to save photo: \(error.localizedDescription)")
            return nil
        }
    }

    func saveArtwork(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = artworkURL.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            logger.info("Artwork saved: \(fileName)")
            return "\(artworkDir)/\(fileName)"
        } catch {
            logger.error("Failed to save artwork: \(error.localizedDescription)")
            return nil
        }
    }

    func saveAudio(data: Data) -> String? {
        let fileName = "\(UUID().uuidString).m4a"
        let fileURL = audioURL.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            logger.info("Audio saved: \(fileName)")
            return "\(audioDir)/\(fileName)"
        } catch {
            logger.error("Failed to save audio: \(error.localizedDescription)")
            return nil
        }
    }

    func loadImage(at relativePath: String) -> UIImage? {
        let fileURL = supportDir.appendingPathComponent(relativePath)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            logger.warning("Image not found at: \(relativePath)")
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }

    func deleteImage(at relativePath: String) {
        let fileURL = supportDir.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: fileURL)
        logger.info("Image deleted: \(relativePath)")
    }

    func deleteAll() {
        for dir in [photosURL, artworkURL, audioURL] {
            try? FileManager.default.removeItem(at: dir)
        }
        createDirectories()
        logger.info("All storage cleared")
    }
}
