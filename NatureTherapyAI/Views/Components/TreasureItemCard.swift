import SwiftUI

struct TreasureItem: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let instruction: String
    var status: Status = .pending
    var feedbackMessage: String?

    enum Status: Equatable {
        case pending
        case found(UIImage)
        case skipped
    }
}

struct TreasureItemCard: View {
    let item: TreasureItem
    let onCapture: () -> Void
    let onConfirm: () -> Void
    let onSkip: () -> Void

    @State private var showFeedback = false

    private var isPending: Bool { item.status == .pending }
    private var isFound: Bool {
        if case .found = item.status { return true }
        return false
    }
    private var isSkipped: Bool { item.status == .skipped }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow

            if isPending {
                instructionText
            }

            if isFound, let feedback = item.feedbackMessage {
                feedbackBanner(feedback)
            }

            if isSkipped {
                skippedBanner
            }

            actionButtons
        }
        .padding(AppTheme.compactPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(
                    isFound
                        ? AppTheme.lightGreen.opacity(0.15)
                        : AppTheme.cardWhite
                )
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(
                    isFound
                        ? AppTheme.forestGreen.opacity(0.4)
                        : isSkipped
                            ? AppTheme.secondaryText.opacity(0.3)
                            : AppTheme.softOrange.opacity(0.3),
                    lineWidth: isFound ? 2 : 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.emoji) \(item.name). \(item.instruction). Status: \(statusAccessibilityText)")
    }

    private var headerRow: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 52, height: 52)

                Text(item.emoji)
                    .font(.system(size: 28))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)

                Text(statusLabel)
                    .font(AppTheme.captionFont)
                    .foregroundColor(statusColor)
            }

            Spacer()

            statusBadge
        }
    }

    private var instructionText: some View {
        Text(item.instruction)
            .font(AppTheme.bodyFont)
            .foregroundColor(AppTheme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 4)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            if isPending {
                LargeActionButton(
                    title: "Ambil Gambar",
                    icon: "camera.fill",
                    color: AppTheme.forestGreen
                ) {
                    onCapture()
                }
            }

            if isFound {
                LargeActionButton(
                    title: "Sahkan",
                    icon: "checkmark.circle.fill",
                    color: AppTheme.emerald
                ) {
                    withAnimation(AppAnimation.smooth) {
                        showFeedback = true
                    }
                    onConfirm()
                }
            }

            if !isSkipped {
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

    private func feedbackBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Text("⭐")
                .font(.system(size: 22))
                .accessibilityHidden(true)

            Text(message)
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.forestGreen)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.lightGreen.opacity(0.3))
        )
    }

    private var skippedBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "forward.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.secondaryText)

            Text("Dilangkau")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(.horizontal, 4)
    }

    private var statusColor: Color {
        if isFound { return AppTheme.forestGreen }
        if isSkipped { return AppTheme.secondaryText }
        return AppTheme.softOrange
    }

    private var statusLabel: String {
        switch item.status {
        case .pending: return "Belum diambil"
        case .found: return "Gambar dijumpai!"
        case .skipped: return "Dilangkau"
        }
    }

    private var statusAccessibilityText: String {
        switch item.status {
        case .pending: return "belum diambil"
        case .found: return "gambar dijumpai"
        case .skipped: return "dilangkau"
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if isFound {
            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.softOrange)
                .accessibilityHidden(true)
        } else if isSkipped {
            Image(systemName: "forward.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.secondaryText)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.softOrange)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 14) {
            TreasureItemCard(
                item: TreasureItem(
                    id: "1",
                    name: "Daun Besar",
                    emoji: "🍃",
                    instruction: "Cari daun yang lebih besar dari tangan anda!"
                ),
                onCapture: {},
                onConfirm: {},
                onSkip: {}
            )

            TreasureItemCard(
                item: TreasureItem(
                    id: "2",
                    name: "Bunga Warni",
                    emoji: "🌺",
                    instruction: "Jumpa bunga yang berwarna terang!",
                    status: .found(UIImage()),
                    feedbackMessage: "Hebat! Anda jumpa bunga yang cantik!"
                ),
                onCapture: {},
                onConfirm: {},
                onSkip: {}
            )

            TreasureItemCard(
                item: TreasureItem(
                    id: "3",
                    name: "Batu Licin",
                    emoji: "🪨",
                    instruction: "Cari batu yang licin dan bulat.",
                    status: .skipped
                ),
                onCapture: {},
                onConfirm: {},
                onSkip: {}
            )
        }
        .padding()
    }
    .background(AppTheme.backgroundGradient)
}
