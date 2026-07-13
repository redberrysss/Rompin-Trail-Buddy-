import SwiftUI

struct SensoryStationCard: View {
    let stationNumber: Int
    let title: String
    let emoji: String
    @Binding var selectedOptions: Set<String>
    @Binding var selectedEmotion: Emotion?
    var availableOptions: [String] = []
    var isCompleted: Bool = false
    let onSkip: () -> Void

    private var totalSteps: Int { max(1, availableOptions.count + 1) }
    private var completedSteps: Int {
        var count = 0
        if !selectedOptions.isEmpty { count += 1 }
        if selectedEmotion != nil { count += 1 }
        return count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            optionsSection
            emotionSection
            actionRow
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(
                    isCompleted
                        ? AppTheme.lightGreen.opacity(0.15)
                        : AppTheme.cardWhite
                )
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(
                    isCompleted ? AppTheme.forestGreen.opacity(0.3) : AppTheme.dividerColor,
                    lineWidth: isCompleted ? 2 : 1
                )
        )
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.forestGreen.opacity(0.15))
                    .frame(width: 48, height: 48)

                Text(emoji)
                    .font(.system(size: 24))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Stesen \(stationNumber)")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.forestGreen)

                Text(title)
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)
            }

            Spacer()

            ProgressHeader(current: completedSteps, total: totalSteps)
                .frame(width: 80)
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !availableOptions.isEmpty {
                Text("Pilih yang anda jumpa:")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                FlowLayout(spacing: 10) {
                    ForEach(availableOptions, id: \.self) { option in
                        optionChip(option)
                    }
                }
            }
        }
    }

    private func optionChip(_ option: String) -> some View {
        let isSelected = selectedOptions.contains(option)
        return Button(action: {
            withAnimation(AppAnimation.fast) {
                if isSelected {
                    selectedOptions.remove(option)
                } else {
                    selectedOptions.insert(option)
                }
            }
        }) {
            Text(option)
                .font(AppTheme.subheadline)
                .foregroundColor(isSelected ? .white : AppTheme.darkGreen)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.forestGreen : AppTheme.lightGreen.opacity(0.25))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? AppTheme.forestGreen : AppTheme.dividerColor,
                            lineWidth: 1
                        )
                )
        }
        .accessibilityLabel(option)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bagaimana perasaan anda?")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 10
            ) {
                ForEach(Emotion.allCases) { emotion in
                    EmotionCard(
                        emotion: emotion.rawValue,
                        emoji: emotion.emoji,
                        isSelected: selectedEmotion == emotion,
                        action: {
                            withAnimation(AppAnimation.fast) {
                                selectedEmotion = emotion
                            }
                        }
                    )
                }
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            LargeActionButton(
                title: "Langkau",
                icon: "forward.fill",
                color: AppTheme.secondaryText
            ) {
                onSkip()
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() where index < subviews.count {
            subviews[index].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
        let containerWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        return (CGSize(width: totalWidth, height: currentY + rowHeight), origins)
    }
}

#Preview {
    @Previewable @State var options: Set<String> = []
    @Previewable @State var emotion: Emotion? = nil

    ScrollView {
        SensoryStationCard(
            stationNumber: 1,
            title: "Sentuhan Alam",
            emoji: "🌿",
            selectedOptions: $options,
            selectedEmotion: $emotion,
            availableOptions: ["Daun lembut", "Kulit kayu", "Tanah lembap", "Batu licin", "Rumput"],
            onSkip: {}
        )
        .padding()
    }
    .background(AppTheme.backgroundGradient)
}
