import AVFoundation
import OSLog

final class AudioStorageService: NSObject {
    static let shared = AudioStorageService()
    private let logger = Logger(subsystem: "com.rompinforest.storage", category: "AudioStorage")

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    var isRecording = false

    private var audioDir: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("RompinForestExplorer/Audio")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording() -> Bool {
        let fileName = "\(UUID().uuidString).m4a"
        let url = audioDir.appendingPathComponent(fileName)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            recordingURL = url
            isRecording = true
            logger.info("Audio recording started")
            return true
        } catch {
            logger.error("Failed to start recording: \(error.localizedDescription)")
            return false
        }
    }

    func stopRecording() -> String? {
        audioRecorder?.stop()
        isRecording = false
        guard let url = recordingURL,
              FileManager.default.fileExists(atPath: url.path) else {
            logger.warning("No audio file recorded")
            return nil
        }
        let relativePath = "RompinForestExplorer/Audio/\(url.lastPathComponent)"
        logger.info("Audio saved: \(relativePath)")
        recordingURL = nil
        return relativePath
    }

    func playAudio(at relativePath: String) {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = support.appendingPathComponent(relativePath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            logger.warning("Audio file not found: \(relativePath)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            logger.error("Failed to play audio: \(error.localizedDescription)")
        }
    }

    func deleteAudio(at relativePath: String) {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = support.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: url)
        logger.info("Audio deleted: \(relativePath)")
    }
}
