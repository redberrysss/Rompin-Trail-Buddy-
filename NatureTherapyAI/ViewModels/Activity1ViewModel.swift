import SwiftUI
import SwiftData
import OSLog

@MainActor
final class Activity1ViewModel: ObservableObject {
    struct ObservationItem: Identifiable {
        let id = UUID()
        let name: String
        let englishName: String
        let category: String
        let emoji: String
        var isCompleted = false
        var isSkipped = false
        var imagePath: String?
        var detectedLabel: String?
        var confidence: Double?
        var ocrText: String?
        var isConfirmed = false
    }

    @Published var items: [ObservationItem] = []
    @Published var currentStep = 0
    @Published var capturedImage: UIImage?
    @Published var detectionResults: [DetectionResult] = []
    @Published var ocrDetectedText = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var progress: Double = 0
    @Published var showCompletion = false
    @Published var isOCRMode = false

    var sessionID: UUID?
    var participantID: UUID?
    private let logger = Logger(subsystem: "com.rompinforest.activity1", category: "ViewModel")

    init() {
        resetItems()
    }

    private func resetItems() {
        items = [
            ObservationItem(name: "Burung", englishName: "Bird", category: "animal", emoji: "\u{1F426}"),
            ObservationItem(name: "Rama-rama", englishName: "Butterfly", category: "animal", emoji: "\u{1F98B}"),
            ObservationItem(name: "Serangga", englishName: "Insect", category: "animal", emoji: "\u{1F41B}"),
            ObservationItem(name: "Daun", englishName: "Leaf", category: "plant", emoji: "\u{1F343}"),
            ObservationItem(name: "Bunga", englishName: "Flower", category: "plant", emoji: "\u{1F338}"),
            ObservationItem(name: "Pokok", englishName: "Tree", category: "plant", emoji: "\u{1F333}")
        ]
    }

    var currentItem: ObservationItem? {
        guard currentStep < items.count else { return nil }
        return items[currentStep]
    }

    var isComplete: Bool {
        items.allSatisfy { $0.isCompleted || $0.isSkipped }
    }

    var completedCount: Int {
        items.filter { $0.isCompleted || $0.isSkipped }.count
    }

    func startSession(participantID: UUID, context: ModelContext) {
        self.participantID = participantID
        let session = DatabaseService.shared.createSession(participantID: participantID, activityNumber: 1, context: context)
        sessionID = session.id
    }

    func capturePhoto(_ image: UIImage) {
        capturedImage = image
    }

    func retakePhoto() {
        capturedImage = nil
        detectionResults = []
        ocrDetectedText = ""
        errorMessage = nil
    }

    func runDetection() async {
        guard let image = capturedImage else {
            errorMessage = "Sila ambil gambar terlebih dahulu."
            return
        }
        isProcessing = true
        errorMessage = nil

        if isOCRMode {
            let text = await ObjectDetectionService.shared.performOCR(on: image)
            ocrDetectedText = text
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorMessage = "Teks tidak dapat dikesan. Cuba mod objek."
            } else {
                let lower = text.lowercased()
                var matched = false
                for (index, item) in items.enumerated() {
                    let keywords = [item.name.lowercased(), item.englishName.lowercased()]
                    if keywords.contains(where: { lower.contains($0) }) {
                        items[index].detectedLabel = item.name
                        items[index].confidence = 1.0
                        matched = true
                        break
                    }
                }
                if !matched {
                    errorMessage = "Objek tidak dikenal pasti dalam teks. Sila pilih secara manual."
                }
            }
        } else {
            let results = await ObjectDetectionService.shared.detectObjects(in: image)
            detectionResults = results
            if let best = results.first {
                updateCurrentItem(detectedLabel: best.objectName, confidence: Double(best.confidence))
            } else {
                errorMessage = "Objek tidak dapat dikenal pasti. Sila pilih objek secara manual."
            }
        }
        isProcessing = false
    }

    private func updateCurrentItem(detectedLabel: String, confidence: Double) {
        guard currentStep < items.count else { return }
        items[currentStep].detectedLabel = detectedLabel
        items[currentStep].confidence = confidence
    }

    func confirmDetection() {
        guard currentStep < items.count else { return }
        items[currentStep].isConfirmed = true
        items[currentStep].isCompleted = true
        saveImageIfNeeded()
        advanceStep()
    }

    func skipItem() {
        guard currentStep < items.count else { return }
        items[currentStep].isSkipped = true
        advanceStep()
    }

    func manuallySelect(itemName: String) {
        guard currentStep < items.count else { return }
        items[currentStep].detectedLabel = itemName
        items[currentStep].isConfirmed = true
        items[currentStep].isCompleted = true
        saveImageIfNeeded()
        advanceStep()
    }

    private func saveImageIfNeeded() {
        guard currentStep < items.count,
              let image = capturedImage,
              let path = ImageStorageService.shared.savePhoto(image: image) else { return }
        items[currentStep].imagePath = path
    }

    private func advanceStep() {
        updateProgress()
        if currentStep < items.count - 1 {
            currentStep += 1
            capturedImage = nil
            detectionResults = []
            ocrDetectedText = ""
            errorMessage = nil
        }
        if isComplete {
            progress = 1.0
            showCompletion = true
        }
    }

    private func updateProgress() {
        progress = Double(completedCount) / Double(items.count)
    }

    func saveObservation(for item: ObservationItem, context: ModelContext) {
        let _ = DatabaseService.shared.saveObservation(
            sessionID: sessionID ?? UUID(),
            participantID: participantID ?? UUID(),
            activityNumber: 1,
            category: item.category,
            objectName: item.name,
            detectedLabel: item.detectedLabel,
            confidence: item.confidence,
            ocrText: item.ocrText,
            imagePath: item.imagePath,
            isConfirmed: item.isConfirmed,
            isSkipped: item.isSkipped,
            context: context
        )
    }

    func saveAllObservations(context: ModelContext) {
        for item in items {
            saveObservation(for: item, context: context)
        }
    }

    func completeActivity(context: ModelContext) {
        guard let sid = sessionID else {
            errorMessage = "Sesi tidak dijumpai."
            return
        }
        saveAllObservations(context: context)
        if let session = DatabaseService.shared.fetchActiveSession(
            participantID: participantID ?? UUID(),
            activityNumber: 1,
            context: context
        ) {
            DatabaseService.shared.completeSession(session, context: context)
        } else {
            let descriptor = FetchDescriptor<ActivitySession>(
                predicate: #Predicate { $0.id == sid }
            )
            if let session = try? context.fetch(descriptor).first {
                DatabaseService.shared.completeSession(session, context: context)
            }
        }
        progress = 1.0
        showCompletion = true
    }

    func resetActivity() {
        resetItems()
        currentStep = 0
        capturedImage = nil
        detectionResults = []
        ocrDetectedText = ""
        errorMessage = nil
        progress = 0
        showCompletion = false
        isOCRMode = false
        sessionID = nil
    }
}
