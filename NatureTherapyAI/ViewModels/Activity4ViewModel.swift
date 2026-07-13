import SwiftUI
import SwiftData
import OSLog

@MainActor
final class Activity4ViewModel: ObservableObject {
    struct GalleryItem: Identifiable {
        let id = UUID()
        let imagePath: String
        let objectName: String
        let date: Date
        let activityNumber: Int
    }

    struct CanvasImage: Identifiable {
        let id = UUID()
        let imagePath: String
        var position: CGSize
        var scale: CGFloat
        var rotation: Angle
        var zIndex: Int
    }

    @Published var galleryItems: [GalleryItem] = []
    @Published var canvasImages: [CanvasImage] = []
    @Published var selectedImages: [GalleryItem] = []
    @Published var selectedBackground: String?
    @Published var title: String = ""
    @Published var showPhysicalMode = false
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var savedArtworks: [ArtworkRecord] = []
    @Published var progress: Double = 0

    var sessionID: UUID?
    var participantID: UUID?
    private let logger = Logger(subsystem: "com.rompinforest.activity4", category: "ViewModel")

    let backgroundOptions = [
        (name: "Putih", color: "\u{2B1C}"),
        (name: "Hijau Daun", color: "\u{1F7E9}"),
        (name: "Biru Langit", color: "\u{1F7E6}"),
        (name: "Coklat Tanah", color: "\u{1F7E8}")
    ]

    let stickerOptions = [
        (name: "Bintang", emoji: "\u{2B50}"),
        (name: "Matahari", emoji: "\u{2600}\u{FE0F}"),
        (name: "Awan", emoji: "\u{2601}\u{FE0F}"),
        (name: "Hati", emoji: "\u{2764}\u{FE0F}"),
        (name: "Pelangi", emoji: "\u{1F308}"),
        (name: "Kupu-kupu", emoji: "\u{1F98B}")
    ]

    init() {}

    func startSession(participantID: UUID, context: ModelContext) {
        self.participantID = participantID
        loadPhotos(context: context)
        loadArtworks(context: context)
        let session = DatabaseService.shared.createSession(participantID: participantID, activityNumber: 4, context: context)
        sessionID = session.id
    }

    func loadPhotos(context: ModelContext) {
        let allPhotos = DatabaseService.shared.fetchAllPhotos(participantID: participantID ?? UUID(), context: context)
        galleryItems = allPhotos.map { (path, name, date, activity) in
            GalleryItem(imagePath: path, objectName: name, date: date, activityNumber: activity)
        }
    }

    func loadArtworks(context: ModelContext) {
        savedArtworks = DatabaseService.shared.fetchArtworks(participantID: participantID ?? UUID(), context: context)
    }

    func selectPhotoFromGallery(_ item: GalleryItem) {
        guard !selectedImages.contains(where: { $0.id == item.id }) else { return }
        selectedImages.append(item)
        let canvasImage = CanvasImage(
            imagePath: item.imagePath,
            position: .zero,
            scale: 1.0,
            rotation: .zero,
            zIndex: canvasImages.count
        )
        canvasImages.append(canvasImage)
    }

    func deselectPhoto(_ item: GalleryItem) {
        selectedImages.removeAll { $0.id == item.id }
        canvasImages.removeAll { $0.imagePath == item.imagePath }
    }

    func addSticker(emoji: String) {
        let emojiImagePath = saveEmojiAsImage(emoji)
        guard let path = emojiImagePath else { return }
        let canvasImage = CanvasImage(
            imagePath: path,
            position: .zero,
            scale: 1.0,
            rotation: .zero,
            zIndex: canvasImages.count
        )
        canvasImages.append(canvasImage)
    }

    private func saveEmojiAsImage(_ emoji: String) -> String? {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        UIRectFill(CGRect(origin: .zero, size: size))
        let text = emoji as NSString
        let font = UIFont.systemFont(ofSize: 80)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let textSize = text.size(withAttributes: attrs)
        let rect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: rect, withAttributes: attrs)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let img = image else { return nil }
        return ImageStorageService.shared.savePhoto(image: img)
    }

    func moveImage(_ id: UUID, by offset: CGSize) {
        guard let index = canvasImages.firstIndex(where: { $0.id == id }) else { return }
        canvasImages[index].position = CGSize(
            width: canvasImages[index].position.width + offset.width,
            height: canvasImages[index].position.height + offset.height
        )
    }

    func updateImagePosition(_ id: UUID, position: CGSize) {
        guard let index = canvasImages.firstIndex(where: { $0.id == id }) else { return }
        canvasImages[index].position = position
    }

    func resizeImage(_ id: UUID, scale: CGFloat) {
        guard let index = canvasImages.firstIndex(where: { $0.id == id }) else { return }
        canvasImages[index].scale = max(0.3, min(3.0, scale))
    }

    func rotateImage(_ id: UUID, angle: Angle) {
        guard let index = canvasImages.firstIndex(where: { $0.id == id }) else { return }
        canvasImages[index].rotation = angle
    }

    func bringToFront(_ id: UUID) {
        guard let index = canvasImages.firstIndex(where: { $0.id == id }) else { return }
        let maxZ = canvasImages.map(\.zIndex).max() ?? 0
        canvasImages[index].zIndex = maxZ + 1
    }

    func removeImage(_ id: UUID) {
        guard let removed = canvasImages.first(where: { $0.id == id }) else { return }
        canvasImages.removeAll { $0.id == id }
        selectedImages.removeAll { $0.imagePath == removed.imagePath }
    }

    func setBackground(_ name: String) {
        selectedBackground = name
    }

    func undo() {
        guard !canvasImages.isEmpty else { return }
        let removed = canvasImages.removeLast()
        selectedImages.removeAll { $0.imagePath == removed.imagePath }
    }

    func resetCanvas() {
        canvasImages.removeAll()
        selectedImages.removeAll()
        selectedBackground = nil
        title = ""
    }

    func saveArtwork(context: ModelContext) {
        guard let pid = participantID, let sid = sessionID else {
            errorMessage = "Sesi tidak aktif."
            return
        }
        guard !canvasImages.isEmpty else {
            errorMessage = "Kain lukisan kosong. Tambah gambar terlebih dahulu."
            return
        }
        isProcessing = true

        let renderSize = CGSize(width: 1024, height: 768)
        let renderer = UIGraphicsImageRenderer(size: renderSize)
        let artworkImage = renderer.image { ctx in
            let background: UIColor = {
                switch selectedBackground {
                case "Putih": return .white
                case "Hijau Daun": return UIColor(red: 0.36, green: 0.70, blue: 0.36, alpha: 1)
                case "Biru Langit": return UIColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1)
                case "Coklat Tanah": return UIColor(red: 0.65, green: 0.46, blue: 0.30, alpha: 1)
                default: return .white
                }
            }()
            background.setFill()
            ctx.fill(CGRect(origin: .zero, size: renderSize))

            for canvasImage in canvasImages.sorted(by: { $0.zIndex < $1.zIndex }) {
                let uiImage = ImageStorageService.shared.loadImage(at: canvasImage.imagePath)
                let cgImage = uiImage?.cgImage
                let imgWidth = CGFloat(cgImage?.width ?? 200)
                let imgHeight = CGFloat(cgImage?.height ?? 200)
                let scaledWidth = imgWidth * canvasImage.scale * 0.3
                let scaledHeight = imgHeight * canvasImage.scale * 0.3
                let drawRect = CGRect(
                    x: canvasImage.position.width + (renderSize.width - scaledWidth) / 2,
                    y: canvasImage.position.height + (renderSize.height - scaledHeight) / 2,
                    width: scaledWidth,
                    height: scaledHeight
                )
                ctx.cgContext.saveGState()
                ctx.cgContext.translateBy(x: drawRect.midX, y: drawRect.midY)
                ctx.cgContext.rotate(by: CGFloat(canvasImage.rotation.radians))
                ctx.cgContext.translateBy(x: -drawRect.midX, y: -drawRect.midY)
                uiImage?.draw(in: drawRect)
                ctx.cgContext.restoreGState()
            }
        }

        guard let savedPath = ImageStorageService.shared.saveArtwork(image: artworkImage) else {
            errorMessage = "Karya seni gagal disimpan."
            isProcessing = false
            return
        }

        let finalTitle = title.trimmingCharacters(in: .whitespaces).isEmpty ? "Karya Seni" : title
        let sourceIDs = canvasImages.map(\.imagePath)
        let _ = DatabaseService.shared.saveArtwork(
            participantID: pid,
            sessionID: sid,
            title: finalTitle,
            artworkImagePath: savedPath,
            sourceImageIDs: sourceIDs,
            artworkType: "digital",
            context: context
        )

        loadArtworks(context: context)
        isProcessing = false
        progress = 1.0
    }

    func capturePhysicalArtwork(_ image: UIImage, context: ModelContext) {
        guard let pid = participantID, let sid = sessionID else {
            errorMessage = "Sesi tidak aktif."
            return
        }
        guard let savedPath = ImageStorageService.shared.savePhoto(image: image) else {
            errorMessage = "Gambar gagal disimpan."
            return
        }
        let _ = DatabaseService.shared.saveArtwork(
            participantID: pid,
            sessionID: sid,
            title: title.isEmpty ? "Karya Fizikal" : title,
            artworkImagePath: savedPath,
            sourceImageIDs: [],
            artworkType: "physical",
            context: context
        )
        loadArtworks(context: context)
        showPhysicalMode = false
        progress = 1.0
    }

    func completeActivity(context: ModelContext) {
        guard let sid = sessionID else {
            errorMessage = "Sesi tidak dijumpai."
            return
        }
        let descriptor = FetchDescriptor<ActivitySession>(
            predicate: #Predicate { $0.id == sid }
        )
        if let session = try? context.fetch(descriptor).first {
            DatabaseService.shared.completeSession(session, context: context)
        }
        progress = 1.0
    }

    func resetActivity() {
        galleryItems = []
        canvasImages = []
        selectedImages = []
        selectedBackground = nil
        title = ""
        showPhysicalMode = false
        isProcessing = false
        errorMessage = nil
        progress = 0
        sessionID = nil
    }
}
