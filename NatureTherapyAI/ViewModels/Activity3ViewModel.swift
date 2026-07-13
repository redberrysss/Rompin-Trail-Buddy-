import SwiftUI
import SwiftData
import OSLog

@MainActor
final class Activity3ViewModel: ObservableObject {
    struct TreasureItem: Identifiable {
        let id = UUID()
        let name: String
        let emoji: String
        let instruction: String
        var isFound = false
        var isSkipped = false
        var imagePath: String?
    }

    @Published var items: [TreasureItem] = []
    @Published var currentStep = 0
    @Published var capturedImage: UIImage?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var progress: Double = 0
    @Published var showCompletion = false
    @Published var positiveFeedback = ""

    var sessionID: UUID?
    var participantID: UUID?
    private let logger = Logger(subsystem: "com.rompinforest.activity3", category: "ViewModel")

    private let feedbackMessages = [
        "Hebat! Kamu menjumpai harta karun alam! \u{1F31F}",
        "Bagus! Teruskan探索! \u{1F44D}",
        "Wah! Alam semula jadi sungguh cantik! \u{1F33F}",
        "Syabas! Kamu seorang peneroka yang hebat! \u{1F3C6}",
        "Menarik! Lihat apa lagi yang kamu boleh jumpa! \u{1F440}"
    ]

    init() {
        resetItems()
    }

    private func resetItems() {
        items = [
            TreasureItem(
                name: "Daun Besar",
                emoji: "\u{1F9E4}",
                instruction: "Cari sehelai daun yang lebih besar daripada tapak tangan kamu."
            ),
            TreasureItem(
                name: "Daun Kecil",
                emoji: "\u{1F342}",
                instruction: "Cari sehelai daun yang lebih kecil daripada ibu jari kamu."
            ),
            TreasureItem(
                name: "Batu Licin",
                emoji: "\u{1FAA8}",
                instruction: "Cari batu yang licin dan selesa dipegang."
            ),
            TreasureItem(
                name: "Bunga Berwarna",
                emoji: "\u{1F490}",
                instruction: "Cari bunga yang mempunyai warna terang."
            ),
            TreasureItem(
                name: "Ranting Panjang",
                emoji: "\u{1FAB6}",
                instruction: "Cari ranting yang lebih panjang daripada pensel."
            )
        ]
    }

    var currentItem: TreasureItem? {
        guard currentStep < items.count else { return nil }
        return items[currentStep]
    }

    var isComplete: Bool {
        items.allSatisfy { $0.isFound || $0.isSkipped }
    }

    var completedCount: Int {
        items.filter { $0.isFound || $0.isSkipped }.count
    }

    func startSession(participantID: UUID, context: ModelContext) {
        self.participantID = participantID
        let session = DatabaseService.shared.createSession(participantID: participantID, activityNumber: 3, context: context)
        sessionID = session.id
    }

    func capturePhoto(_ image: UIImage) {
        guard let path = ImageStorageService.shared.savePhoto(image: image) else {
            errorMessage = "Gambar gagal disimpan."
            return
        }
        capturedImage = image
        guard currentStep < items.count else { return }
        items[currentStep].imagePath = path
    }

    func retakePhoto() {
        capturedImage = nil
        if currentStep < items.count {
            items[currentStep].imagePath = nil
        }
    }

    func markAsFound() {
        guard currentStep < items.count else { return }
        items[currentStep].isFound = true
        positiveFeedback = feedbackMessages[currentStep % feedbackMessages.count]
        advanceStep()
    }

    func skipItem() {
        guard currentStep < items.count else { return }
        items[currentStep].isSkipped = true
        positiveFeedback = "Tidak mengapa. Cuba cari lain kali! \u{1F60A}"
        advanceStep()
    }

    private func advanceStep() {
        updateProgress()
        if currentStep < items.count - 1 {
            currentStep += 1
            capturedImage = nil
            errorMessage = nil
        }
        if isComplete {
            progress = 1.0
            positiveFeedback = "Tahniah! Kamu berjaya menyelesaikan semua cabaran! \u{1F389}"
            showCompletion = true
        }
    }

    private func updateProgress() {
        progress = Double(completedCount) / Double(items.count)
    }

    func saveRecord(for item: TreasureItem, context: ModelContext) {
        let _ = DatabaseService.shared.saveTreasureRecord(
            sessionID: sessionID ?? UUID(),
            participantID: participantID ?? UUID(),
            itemName: item.name,
            imagePath: item.imagePath,
            isFound: item.isFound,
            isSkipped: item.isSkipped,
            context: context
        )
    }

    func saveAllRecords(context: ModelContext) {
        for item in items {
            saveRecord(for: item, context: context)
        }
    }

    func completeActivity(context: ModelContext) {
        guard let sid = sessionID else {
            errorMessage = "Sesi tidak dijumpai."
            return
        }
        saveAllRecords(context: context)
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
        resetItems()
        currentStep = 0
        capturedImage = nil
        isProcessing = false
        errorMessage = nil
        progress = 0
        showCompletion = false
        positiveFeedback = ""
        sessionID = nil
    }
}
