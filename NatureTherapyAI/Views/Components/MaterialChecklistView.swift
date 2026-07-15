import SwiftUI

struct MaterialChecklistView: View {
    let materials: [MaterialItem]
    let onToggle: (MaterialItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bahan-Bahan")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)

            ForEach(materials) { item in
                Button {
                    onToggle(item)
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .stroke(item.isCollected ? AppTheme.successGreen : AppTheme.dividerColor, lineWidth: 2)
                                .frame(width: 28, height: 28)
                            if item.isCollected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.successGreen)
                            }
                        }

                        Text(item.emoji)
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.darkGreen)
                            if let desc = item.description {
                                Text(desc)
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }

                        Spacer()

                        if item.isCollected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.successGreen)
                                .font(.title3)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(item.isCollected ? AppTheme.lightGreen.opacity(0.15) : AppTheme.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(item.isCollected ? AppTheme.lightGreen : AppTheme.dividerColor, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(item.name), \(item.isCollected ? "sudah dikumpul" : "belum dikumpul")")
            }
        }
    }
}

struct MaterialItem: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let description: String?
    var isCollected: Bool = false
}

// MARK: - Volume Control & Mute Component

struct VolumeControlView: View {
    @Binding var volume: Double
    @Binding var isMuted: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button {
                isMuted.toggle()
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : volume > 0.5 ? "speaker.wave.2.fill" : "speaker.wave.1.fill")
                    .font(.title3)
                    .foregroundColor(AppTheme.darkGreen)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.lightGreen.opacity(0.2))
                    .clipShape(Circle())
            }
            .accessibilityLabel(isMuted ? "Bunyikan" : "Kedapkan")

            if !isMuted {
                Slider(value: $volume, in: 0...1)
                    .tint(AppTheme.forestGreen)
                    .accessibilityLabel("Volume")
            }
        }
    }
}

// MARK: - Emotion Picker Component

struct EmotionPickerView: View {
    let title: String
    @Binding var selectedEmotion: String?
    let emotions: [(emoji: String, label: String, value: String)]

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(emotions, id: \.value) { emotion in
                    Button {
                        selectedEmotion = emotion.value
                    } label: {
                        VStack(spacing: 6) {
                            Text(emotion.emoji)
                                .font(.system(size: 32))
                            Text(emotion.label)
                                .font(AppTheme.captionFont)
                                .foregroundColor(selectedEmotion == emotion.value ? .white : AppTheme.darkGreen)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedEmotion == emotion.value ? AppTheme.forestGreen : AppTheme.cardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedEmotion == emotion.value ? AppTheme.forestGreen : AppTheme.dividerColor, lineWidth: 1)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .accessibilityLabel(emotion.label)
                }
            }
        }
    }
}

// MARK: - Activity Step Card

struct StepCardView: View {
    let number: Int
    let title: String
    let description: String
    let icon: String
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCompleted ? AppTheme.successGreen : isActive ? AppTheme.forestGreen : AppTheme.dividerColor)
                    .frame(width: 44, height: 44)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                } else {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.subheadline)
                    .foregroundColor(isActive ? AppTheme.darkGreen : AppTheme.secondaryText)
                Text(description)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()

            if isActive {
                Text("Sekarang")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.forestGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(AppTheme.lightGreen.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isActive ? AppTheme.lightGreen.opacity(0.1) : AppTheme.cardBackground)
        )
        .opacity(isCompleted ? 0.7 : 1)
    }
}
