import SwiftUI
import SwiftData
import OSLog

@MainActor
final class Activity2ViewModel: ObservableObject {
    struct SensoryStation: Identifiable {
        let id = UUID()
        let stationNumber: Int
        let title: String
        let senseType: String
        let emoji: String
        let options: [String]
        let prompt: String
        var selectedValue: String?
        var emotion: String?
        var imagePath: String?
        var audioPath: String?
        var isSkipped = false
        var isCompleted = false
    }

    @Published var stations: [SensoryStation] = []
    @Published var currentStationIndex = 0
    @Published var capturedImage: UIImage?
    @Published var isProcessing = false
    @Published var isRecording = false
    @Published var errorMessage: String?
    @Published var progress: Double = 0
    @Published var showCompletion = false

    var sessionID: UUID?
    var participantID: UUID?
    private let logger = Logger(subsystem: "com.rompinforest.activity2", category: "ViewModel")

    let emotions = [
        (name: "Gembira", emoji: "\u{1F60A}"),
        (name: "Tenang", emoji: "\u{1F60C}"),
        (name: "Tidak Pasti", emoji: "\u{1F914}"),
        (name: "Tidak Selesa", emoji: "\u{1F61E}"),
        (name: "Perlukan Rehat", emoji: "\u{1F634}")
    ]

    init() {
        resetStations()
    }

    private func resetStations() {
        stations = [
            SensoryStation(
                stationNumber: 1,
                title: "Apa Yang Saya Lihat?",
                senseType: "penglihatan",
                emoji: "\u{1F441}\u{FE0F}\u{200D}\u{1F5E8}\u{FE0F}",
                options: ["Hijau", "Coklat", "Kuning", "Merah", "Biru", "Pelbagai Warna"],
                prompt: "Apa warna daun yang kamu nampak?"
            ),
            SensoryStation(
                stationNumber: 2,
                title: "Apa Yang Saya Dengar?",
                senseType: "pendengaran",
                emoji: "\u{1F442}",
                options: ["Burung Bernyanyi", "Daun Bergeser", "Air Mengalir", "Angin Bertiup", "Serangga Berbunyi", "Senyap"],
                prompt: "Apa bunyi yang kamu dengar?"
            ),
            SensoryStation(
                stationNumber: 3,
                title: "Apa Yang Saya Sentuh?",
                senseType: "sentuhan",
                emoji: "\u{1F91A}",
                options: ["Kasar", "Licin", "Lembut", "Keras", "Basah", "Kering"],
                prompt: "Bagaimana tekstur benda yang kamu sentuh?"
            ),
            SensoryStation(
                stationNumber: 4,
                title: "Apa Yang Saya Hidu?",
                senseType: "bau",
                emoji: "\u{1F443}",
                options: ["Wangian Bunga", "Hijau Segar", "Tanah Basah", "Manis", "Tidak Berbau", "Lain-lain"],
                prompt: "Apa bau yang kamu hidu?"
            )
        ]
    }

    var currentStation: SensoryStation? {
        guard currentStationIndex < stations.count else { return nil }
        return stations[currentStationIndex]
    }

    var isComplete: Bool {
        stations.allSatisfy { $0.isCompleted || $0.isSkipped }
    }

    var completedCount: Int {
        stations.filter { $0.isCompleted || $0.isSkipped }.count
    }

    func startSession(participantID: UUID, context: ModelContext) {
        self.participantID = participantID
        let session = DatabaseService.shared.createSession(participantID: participantID, activityNumber: 2, context: context)
        sessionID = session.id
    }

    func selectValue(_ value: String) {
        guard currentStationIndex < stations.count else { return }
        stations[currentStationIndex].selectedValue = value
    }

    func selectEmotion(_ emotion: String) {
        guard currentStationIndex < stations.count else { return }
        stations[currentStationIndex].emotion = emotion
    }

    func confirmStation() {
        guard currentStationIndex < stations.count else { return }
        let station = stations[currentStationIndex]
        guard station.selectedValue != nil else {
            errorMessage = "Sila pilih nilai untuk stesen ini."
            return
        }
        stations[currentStationIndex].isCompleted = true
        advanceStation()
    }

    func skipStation() {
        guard currentStationIndex < stations.count else { return }
        stations[currentStationIndex].isSkipped = true
        advanceStation()
    }

    func capturePhoto(_ image: UIImage) {
        guard currentStationIndex < stations.count,
              let path = ImageStorageService.shared.savePhoto(image: image) else { return }
        stations[currentStationIndex].imagePath = path
        capturedImage = image
    }

    func startRecording() {
        guard currentStationIndex < stations.count else { return }
        let granted = AudioStorageService.shared.startRecording()
        if !granted {
            errorMessage = "Rakaman tidak dapat dimulakan."
            return
        }
        isRecording = true
    }

    func stopRecording() {
        guard let path = AudioStorageService.shared.stopRecording() else {
            errorMessage = "Rakaman gagal disimpan."
            isRecording = false
            return
        }
        guard currentStationIndex < stations.count else { return }
        stations[currentStationIndex].audioPath = path
        isRecording = false
    }

    private func advanceStation() {
        updateProgress()
        if currentStationIndex < stations.count - 1 {
            currentStationIndex += 1
            capturedImage = nil
            errorMessage = nil
        }
        if isComplete {
            progress = 1.0
            showCompletion = true
        }
    }

    private func updateProgress() {
        progress = Double(completedCount) / Double(stations.count)
    }

    func saveCurrentStation(context: ModelContext) {
        guard currentStationIndex < stations.count else { return }
        let station = stations[currentStationIndex]
        guard let selectedValue = station.selectedValue else { return }
        let _ = DatabaseService.shared.saveSensoryRecord(
            sessionID: sessionID ?? UUID(),
            participantID: participantID ?? UUID(),
            stationNumber: station.stationNumber,
            senseType: station.senseType,
            selectedValue: selectedValue,
            emotion: station.emotion,
            imagePath: station.imagePath,
            audioPath: station.audioPath,
            isSkipped: station.isSkipped,
            context: context
        )
    }

    func saveAllStations(context: ModelContext) {
        for station in stations {
            guard let selectedValue = station.selectedValue else { continue }
            let _ = DatabaseService.shared.saveSensoryRecord(
                sessionID: sessionID ?? UUID(),
                participantID: participantID ?? UUID(),
                stationNumber: station.stationNumber,
                senseType: station.senseType,
                selectedValue: selectedValue,
                emotion: station.emotion,
                imagePath: station.imagePath,
                audioPath: station.audioPath,
                isSkipped: station.isSkipped,
                context: context
            )
        }
    }

    func completeActivity(context: ModelContext) {
        guard let sid = sessionID else {
            errorMessage = "Sesi tidak dijumpai."
            return
        }
        saveAllStations(context: context)
        let descriptor = FetchDescriptor<ActivitySession>(
            predicate: #Predicate { $0.id == sid }
        )
        if let session = try? context.fetch(descriptor).first {
            DatabaseService.shared.completeSession(session, context: context)
        }
        progress = 1.0
        showCompletion = true
    }

    func resetActivity() {
        resetStations()
        currentStationIndex = 0
        capturedImage = nil
        isProcessing = false
        isRecording = false
        errorMessage = nil
        progress = 0
        showCompletion = false
        sessionID = nil
    }
}
