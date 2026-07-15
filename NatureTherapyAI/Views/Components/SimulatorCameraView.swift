import SwiftUI

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
                            withAnimation(AppTheme.gentleSpring) {
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
