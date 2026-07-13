import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var soundEnabled = true
    @State private var voiceDescriptions = true
    @State private var largeText = false
    @State private var showModelInfo = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    accessibilitySection
                    modelSection
                    aboutSection
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 30)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.3))
                    .frame(width: 64, height: 64)

                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.forestGreen)
            }

            Text("Settings")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.standardPadding)
    }

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "accessibility.fill", title: "Accessibility")

            VStack(spacing: 0) {
                settingsToggle(icon: "speaker.wave.2.fill", title: "Voice Descriptions", isOn: $voiceDescriptions)
                Divider().padding(.leading, 50)
                settingsToggle(icon: "textformat.size", title: "Large Text", isOn: $largeText)
                Divider().padding(.leading, 50)
                settingsToggle(icon: "bell.fill", title: "Sound Effects", isOn: $soundEnabled)
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
            )
        }
    }

    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "cpu", title: "AI Model")

            VStack(spacing: 0) {
                Button(action: { withAnimation(AppAnimation.smooth) { showModelInfo.toggle() } }) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(AppTheme.lightGreen.opacity(0.2))
                                .frame(width: 36, height: 36)

                            Image(systemName: "cpu")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.forestGreen)
                        }

                        Text("Model Status")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.darkGreen)

                        Spacer()

                        Circle()
                            .fill(ModelHandler.shared.isModelLoaded ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)

                        Text(ModelHandler.shared.isModelLoaded ? "Loaded" : "Not Loaded")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.secondaryText)
                            .rotationEffect(.degrees(showModelInfo ? 180 : 0))
                    }
                    .padding(AppTheme.compactPadding)
                }

                if showModelInfo {
                    Divider().padding(.leading, 50)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("About the AI Model")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.darkGreen)

                        Text("This app uses a Core ML model trained with Roboflow to detect nature objects in real-time. The model recognizes plants, animals, and natural objects commonly found in Malaysian rainforests.")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                            .lineSpacing(3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("To train your own model:")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.darkGreen)
                            Group {
                                Text("1. Collect images in Roboflow")
                                Text("2. Train YOLOv8 model")
                                Text("3. Export to Core ML format")
                                Text("4. Add NatureDetection.mlmodel to project")
                            }
                            .font(AppTheme.smallCaption)
                            .foregroundColor(AppTheme.secondaryText)
                        }
                        .padding(12)
                        .background(AppTheme.lightGreen.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(AppTheme.compactPadding)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
            )
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "info.circle.fill", title: "About")

            VStack(spacing: 0) {
                aboutRow(icon: "info.circle", title: "Version", value: "1.0.0")
                Divider().padding(.leading, 50)
                aboutRow(icon: "photo.on.rectangle", title: "Training Data", value: "Roboflow")
                Divider().padding(.leading, 50)

                Link(destination: URL(string: "https://roboflow.com")!) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(AppTheme.softBlue.opacity(0.2))
                                .frame(width: 36, height: 36)

                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.softBlue)
                        }

                        Text("Train on Roboflow")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.softBlue)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(AppTheme.compactPadding)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
            )
        }
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.forestGreen)

            Text(title)
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
        }
    }

    private func settingsToggle(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.forestGreen)
            }

            Text(title)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.darkGreen)

            Spacer()

            Toggle("", isOn: isOn)
                .tint(AppTheme.forestGreen)
        }
        .padding(AppTheme.compactPadding)
    }

    private func aboutRow(icon: String, title: String, value: String) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.forestGreen)
            }

            Text(title)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.darkGreen)

            Spacer()

            Text(value)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(AppTheme.compactPadding)
    }
}
