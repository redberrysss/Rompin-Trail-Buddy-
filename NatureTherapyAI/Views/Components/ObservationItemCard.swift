import SwiftUI

struct ObservationItem: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    var status: Status = .pending

    enum Status: Equatable {
        case pending
        case captured(UIImage)
        case skipped
    }
}

struct ObservationItemCard: View {
    let item: ObservationItem
    let onCapture: () -> Void
    let onConfirm: () -> Void
    let onSkip: () -> Void

    @State private var isExpanded = false

    private var isPending: Bool { item.status == .pending }
    private var isCaptured: Bool {
        if case .captured = item.status { return true }
        return false
    }
    private var isSkipped: Bool { item.status == .skipped }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Text(item.emoji)
                        .font(.system(size: 30))
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.darkGreen)

                    Text(statusText)
                        .font(AppTheme.captionFont)
                        .foregroundColor(statusColor)
                }

                Spacer()

                statusIcon
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(AppAnimation.smooth) {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(AppTheme.compactPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardWhite)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(
                    isCaptured
                        ? AppTheme.forestGreen.opacity(0.4)
                        : isSkipped
                            ? AppTheme.secondaryText.opacity(0.3)
                            : AppTheme.dividerColor,
                    lineWidth: isCaptured ? 2 : 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name). \(statusAccessibilityLabel)")
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var expandedContent: some View {
        if let capturedImage = capturedImage {
            Image(uiImage: capturedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius))
                .padding(.top, 4)
        }

        if isPending || isCaptured {
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

                if isCaptured {
                    LargeActionButton(
                        title: "Sahkan",
                        icon: "checkmark.circle.fill",
                        color: AppTheme.emerald
                    ) {
                        onConfirm()
                    }
                }

                LargeActionButton(
                    title: "Langkau",
                    icon: "forward.fill",
                    color: AppTheme.secondaryText
                ) {
                    onSkip()
                }
            }
            .padding(.top, 4)
        }
    }

    private var statusColor: Color {
        if isCaptured { return AppTheme.forestGreen }
        if isSkipped { return AppTheme.secondaryText }
        return AppTheme.softOrange
    }

    private var statusText: String {
        switch item.status {
        case .pending: return "Menunggu"
        case .captured: return "Gambar diambil"
        case .skipped: return "Dilangkau"
        }
    }

    private var statusAccessibilityLabel: String {
        switch item.status {
        case .pending: return "Status: menunggu"
        case .captured: return "Status: gambar sudah diambil"
        case .skipped: return "Status: dilangkau"
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        if isCaptured {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 26))
                .foregroundColor(AppTheme.forestGreen)
        } else if isSkipped {
            Image(systemName: "forward.circle.fill")
                .font(.system(size: 26))
                .foregroundColor(AppTheme.secondaryText)
        } else {
            Image(systemName: "camera.circle.fill")
                .font(.system(size: 26))
                .foregroundColor(AppTheme.softOrange)
        }
    }

    private var capturedImage: UIImage? {
        if case .captured(let img) = item.status {
            return img
        }
        return nil
    }
}

#Preview {
    @Previewable @State var items = [
        ObservationItem(id: "1", name: "Pokok Besar", emoji: "🌳"),
        ObservationItem(id: "2", name: "Bunga", emoji: "🌸", status: .skipped),
        ObservationItem(id: "3", name: "Burung", emoji: "🐦"),
    ]

    ScrollView {
        VStack(spacing: 14) {
            ForEach($items) { $item in
                ObservationItemCard(
                    item: item,
                    onCapture: {},
                    onConfirm: {},
                    onSkip: {}
                )
            }
        }
        .padding()
    }
    .background(AppTheme.backgroundGradient)
}
