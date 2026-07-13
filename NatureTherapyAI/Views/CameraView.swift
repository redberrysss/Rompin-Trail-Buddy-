import SwiftUI
import SwiftData
import AVFoundation

struct CameraView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CameraViewModel()
    @State private var showInfoCard = false
    @State private var selectedDetection: DetectionResult?
    @State private var detectedInfo: NatureObject?
    @State private var infoCardOffset: CGFloat = 400

    var body: some View {
        ZStack {
            if viewModel.isSimulatorMode {
                SimulatorCameraView(viewModel: viewModel)
            } else {
                realCameraContent
            }

            VStack {
                headerOverlay
                Spacer()
                if !viewModel.isSimulatorMode {
                    detectionChips
                        .padding(.bottom, 100)
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
                        withAnimation(AppAnimation.spring) {
                            selectedDetection = detection
                            detectedInfo = NatureObject.sample(for: detection.objectName)
                            showInfoCard = true
                        }
                    }
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
                    }
                } else {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
        }
    }

    private var scanOverlay: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.ultraThinMaterial)
                    .frame(height: 180)

                VStack(spacing: 8) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 32, weight: .thin))
                        .foregroundColor(.white.opacity(0.7))

                    Text("Point at nature objects to identify them")
                        .font(AppTheme.captionFont)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private var headerOverlay: some View {
        VStack {
            HStack {
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
                        withAnimation(AppAnimation.spring) {
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
                        withAnimation(AppAnimation.spring) {
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
                        withAnimation(AppAnimation.spring) {
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

struct SimulatorCameraView: View {
    @ObservedObject var viewModel: CameraViewModel
    @State private var selectedPreset = 0

    let samplePresets = [
        ("Forest", "🌳"),
        ("River", "🏞️"),
        ("Garden", "🌸"),
        ("Wildlife", "🐦")
    ]

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.1, blue: 0.08)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if let error = viewModel.simulatorCamera?.modelError {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.exclamationmark")
                            .font(.system(size: 44))
                            .foregroundColor(AppTheme.softOrange)
                        Text(error)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 120)
                } else if let image = viewModel.simulatorCamera?.currentImage {
                    ZStack {
                        Image(decorative: image, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)

                        BoundingBoxOverlay(
                            detections: viewModel.detections
                        ) { detection in
                            withAnimation(AppAnimation.spring) {
                                viewModel.showDiscoveryFor(detection: detection)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.standardPadding)
                    .padding(.top, 100)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.12, green: 0.14, blue: 0.12))
                        .frame(height: 320)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(AppTheme.lightGreen)
                                Text("Simulator Ready")
                                    .font(AppTheme.subheadline)
                                    .foregroundColor(.white)
                                Text("Start to test AI detection")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        )
                        .padding(.horizontal, AppTheme.standardPadding)
                        .padding(.top, 100)
                }

                if !viewModel.detections.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.detections) { result in
                                Button(action: { viewModel.showDiscoveryFor(detection: result) }) {
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
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.standardPadding)
                    }
                    .padding(.top, 12)
                }

                Spacer()

                HStack(spacing: 14) {
                    ForEach(Array(samplePresets.enumerated()), id: \.offset) { index, preset in
                        Button(action: {
                            selectedPreset = index
                            viewModel.simulatorCamera?.selectPreset(index)
                        }) {
                            VStack(spacing: 5) {
                                Text(preset.1)
                                    .font(.system(size: 22))
                                Text(preset.0)
                                    .font(AppTheme.smallCaption)
                                    .foregroundColor(selectedPreset == index ? .white : .white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedPreset == index ? AppTheme.forestGreen : Color.white.opacity(0.08))
                            )
                        }
                    }
                }
                .padding(.horizontal, AppTheme.standardPadding)

                Button(action: {
                    if viewModel.simulatorCamera?.isRunning == true {
                        viewModel.simulatorCamera?.stopSimulatorCamera()
                    } else {
                        viewModel.simulatorCamera?.startSimulatorCamera()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.simulatorCamera?.isRunning == true ? "stop.fill" : "play.fill")
                        Text(viewModel.simulatorCamera?.isRunning == true ? "Stop" : "Start Detection")
                    }
                    .font(AppTheme.largeButtonFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                            .fill(viewModel.simulatorCamera?.isRunning == true ? Color.red : AppTheme.forestGreen)
                            .shadow(color: (viewModel.simulatorCamera?.isRunning == true ? Color.red : AppTheme.forestGreen).opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 30)
                .padding(.top, 12)
            }
        }
    }
}
