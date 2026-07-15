import SwiftUI
import SwiftData
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CameraViewModel()
    @State private var showInfoCard = false
    @State private var selectedDetection: DetectionResult?
    @State private var detectedInfo: NatureObject?
    @State private var infoCardOffset: CGFloat = 400
    @State private var discoveryName = ""
    @State private var selectedCategory = "alam"
    @State private var showSaveDialog = false

    private let categories = ["alam", "pokok", "bunga", "serangga", "burung", "haiwan"]

    var body: some View {
        ZStack {
            if viewModel.showPreview, let image = viewModel.capturedImage {
                previewContent(image: image)
            } else if viewModel.isSimulatorMode {
                SimulatorCameraView(viewModel: viewModel)
            } else {
                realCameraContent
            }

            if !viewModel.showPreview {
                VStack {
                    headerOverlay
                    Spacer()
                    if !viewModel.isSimulatorMode {
                        detectionChips
                            .padding(.bottom, 100)
                    }
                }
            }

            if let detection = selectedDetection, showInfoCard {
                infoCardOverlay(detection: detection)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.setup(modelContext: modelContext)
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .fullScreenCover(isPresented: $viewModel.showDiscovery) {
            if let object = viewModel.detectedObject {
                DiscoveryDetailView(natureObject: object)
            }
        }
    }

    private var realCameraContent: some View {
        ZStack {
            if viewModel.isCameraReady {
                CameraPreview(session: viewModel.cameraSession ?? AVCaptureSession())
                    .ignoresSafeArea()

                scanOverlay

                if !viewModel.detections.isEmpty {
                    BoundingBoxOverlay(detections: viewModel.detections) { detection in
                        withAnimation(AppTheme.gentleSpring) {
                            selectedDetection = detection
                            detectedInfo = NatureObject.sample(for: detection.objectName)
                            showInfoCard = true
                        }
                    }
                }

                VStack {
                    Spacer()
                    captureButton
                        .padding(.bottom, 50)
                }
            } else {
                Color.black.ignoresSafeArea()
                if let error = viewModel.cameraError {
                    VStack(spacing: 16) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.5))
                        Text(error)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        if error.contains("ditolak") || error.contains("denied") || error.contains("Settings") {
                            Button("Buka Tetapan") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(AppTheme.bodyFont.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                } else {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
        }
    }

    private var captureButton: some View {
        Button(action: {
            viewModel.capturePhoto()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 80, height: 80)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ambil Gambar")
        .disabled(viewModel.isUploading)
    }

    private func previewContent(image: UIImage) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button("Ambil Semula") {
                        viewModel.retakePhoto()
                    }
                    .font(AppTheme.bodyFont.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer()
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.top, 60)

                Spacer()

                VStack(spacing: 12) {
                    if let error = viewModel.uploadError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(AppTheme.captionFont)
                                .foregroundColor(.red)
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    if viewModel.isUploading {
                        HStack(spacing: 12) {
                            ProgressView()
                                .tint(.white)
                            Text(viewModel.uploadStatus ?? "Memuat naik...")
                                .font(AppTheme.bodyFont)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Button(action: {
                            showSaveDialog = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Simpan")
                            }
                            .font(AppTheme.largeButtonFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                    .fill(AppTheme.primaryGradient)
                                    .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal, AppTheme.standardPadding)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .alert("Simpan Penemuan", isPresented: $showSaveDialog) {
            TextField("Nama penemuan", text: $discoveryName)
            Picker("Kategori", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { cat in
                    Text(cat.capitalized).tag(cat)
                }
            }
            Button("Simpan") {
                Task {
                    await viewModel.savePhoto(discoveryName: discoveryName.isEmpty ? "Penemuan Baru" : discoveryName, category: selectedCategory)
                }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Namakan penemuan anda dan pilih kategori.")
        }
    }

    private var scanOverlay: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.ultraThinMaterial)
                    .frame(height: 120)

                VStack(spacing: 6) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundColor(.white.opacity(0.7))

                    Text("Arahkan ke objek alam untuk dikenal pasti")
                        .font(AppTheme.captionFont)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
    }

    private var headerOverlay: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .accessibilityLabel("Tutup Kamera")

                if viewModel.isSimulatorMode {
                    HStack(spacing: 6) {
                        Image(systemName: "iphone.gen3")
                            .font(.system(size: 12))
                        Text("Simulator")
                            .font(AppTheme.smallCaption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }

                Spacer()

                if viewModel.isSimulatorMode {
                    statusBadge
                }
            }
            .padding(.horizontal, AppTheme.standardPadding)
            .padding(.top, 60)

            Spacer()
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(viewModel.simulatorCamera?.isRunning == true ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(viewModel.simulatorCamera?.isRunning == true ? "Live" : "Standby")
                .font(AppTheme.smallCaption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var detectionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.detections) { result in
                    Button(action: {
                        withAnimation(AppTheme.gentleSpring) {
                            selectedDetection = result
                            detectedInfo = NatureObject.sample(for: result.objectName)
                            showInfoCard = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(result.objectName)
                                .font(AppTheme.captionFont)
                                .foregroundColor(.white)

                            Text(result.confidencePercentage)
                                .font(AppTheme.smallCaption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(AppTheme.forestGreen.opacity(0.85))
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, AppTheme.standardPadding)
        }
    }

    private func infoCardOverlay(detection: DetectionResult) -> some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                HStack {
                    Text(detectedInfo?.emoji ?? "🌱")
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(detection.objectName)
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.darkGreen)

                        HStack(spacing: 8) {
                            Image(systemName: detection.confidence > 0.7 ? "bolt.fill" : "bolt")
                                .font(.system(size: 10))
                            Text(detection.confidencePercentage)
                                .font(AppTheme.captionFont)
                        }
                        .foregroundColor(detection.confidence > 0.7 ? AppTheme.emerald : AppTheme.softOrange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(detection.confidence > 0.7 ? AppTheme.emerald.opacity(0.12) : AppTheme.softOrange.opacity(0.12))
                        )
                    }

                    Spacer()

                    Button(action: {
                        withAnimation(AppTheme.gentleSpring) {
                            showInfoCard = false
                            selectedDetection = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.secondaryText)
                            .background(Circle().fill(.white))
                    }
                }

                Text(detectedInfo?.objectDescription ?? "A wonderful part of nature.")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)

                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.showDiscoveryFor(detection: detection)
                    }) {
                        Label("Learn More", systemImage: "book.fill")
                            .font(AppTheme.captionFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.primaryGradient)
                            )
                    }

                    Button(action: {
                        withAnimation(AppTheme.gentleSpring) {
                            showInfoCard = false
                            selectedDetection = nil
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.secondaryText)
                            .frame(width: 48, height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.cardBackground)
                            )
                    }
                }
            }
            .padding(AppTheme.standardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: -5)
            )
            .padding(.horizontal, AppTheme.standardPadding)
            .padding(.bottom, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
