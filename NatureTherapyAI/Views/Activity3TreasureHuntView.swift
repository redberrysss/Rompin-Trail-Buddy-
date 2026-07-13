import SwiftUI
import SwiftData

struct Activity3TreasureHuntView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = Activity3ViewModel()

    let participantID: UUID
    let participantName: String

    @State private var showCamera = false
    @State private var showFeedback = false
    @State private var hasStartedSession = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            if viewModel.showCompletion {
                completionView
            } else {
                mainContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Kembali")
                            .font(AppTheme.subheadline)
                    }
                    .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(image: Binding(
                get: { viewModel.capturedImage },
                set: { newImage in
                    if let image = newImage {
                        viewModel.capturePhoto(image)
                    }
                }
            ))
            .ignoresSafeArea()
        }
        .onChange(of: viewModel.positiveFeedback) { _, newValue in
            if !newValue.isEmpty && viewModel.showCompletion {
                withAnimation(AppAnimation.spring) {
                    showFeedback = true
                }
            }
        }
        .animation(AppAnimation.smooth, value: viewModel.showCompletion)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection

                ProgressHeader(
                    current: viewModel.completedCount,
                    total: viewModel.items.count,
                    showPercentage: false
                )

                if let item = viewModel.currentItem {
                    if viewModel.capturedImage == nil {
                        instructionSection(item: item)
                    } else {
                        previewSection
                    }
                }

                itemListSection
            }
            .padding(.horizontal, AppTheme.standardPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Aktiviti 3: Nature Treasure Hunt")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)
                .multilineTextAlignment(.center)

            Text("Meningkatkan kemahiran penyelesaian masalah dan perhatian.")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Instruction Section

    private func instructionSection(item: Activity3ViewModel.TreasureItem) -> some View {
        VStack(spacing: 16) {
            VisualInstructionCard(
                emoji: item.emoji,
                title: item.name,
                description: item.instruction,
                stepLabel: "Item \(viewModel.currentStep + 1) daripada \(viewModel.items.count)"
            )

            if showFeedback && !viewModel.positiveFeedback.isEmpty {
                feedbackBanner
            }

            cameraButton

            skipButton
        }
    }

    // MARK: - Camera Button

    private var cameraButton: some View {
        LargeActionButton(
            title: "Ambil Gambar",
            icon: "camera.fill",
            color: AppTheme.forestGreen
        ) {
            showCamera = true
        }
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        LargeActionButton(
            title: "Langkau",
            icon: "forward.fill",
            color: AppTheme.secondaryText
        ) {
            withAnimation(AppAnimation.smooth) {
                viewModel.skipItem()
                showFeedback = false
            }
        }
    }

    // MARK: - Feedback Banner

    private var feedbackBanner: some View {
        HStack(spacing: 12) {
            Text("⭐")
                .font(.system(size: 28))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.positiveFeedback)
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.forestGreen)

                Text("Anda berjaya menjumpainya!")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.softOrange)
                .accessibilityHidden(true)
        }
        .padding(AppTheme.compactPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.lightGreen.opacity(0.3), AppTheme.warmBeige.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(AppTheme.forestGreen.opacity(0.3), lineWidth: 2)
        )
        .transition(.scale.combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.positiveFeedback) Anda berjaya menjumpainya!")
    }

    // MARK: - Photo Preview Section

    private var previewSection: some View {
        VStack(spacing: 16) {
            if let image = viewModel.capturedImage {
                PhotoPreviewView(
                    image: image,
                    onConfirm: {
                        withAnimation(AppAnimation.spring) {
                            viewModel.markAsFound()
                            showFeedback = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            showFeedback = false
                        }
                    },
                    onRetake: {
                        withAnimation(AppAnimation.smooth) {
                            viewModel.retakePhoto()
                            showFeedback = false
                        }
                    },
                    onSkip: {
                        withAnimation(AppAnimation.smooth) {
                            viewModel.skipItem()
                            showFeedback = false
                        }
                    }
                )
            }
        }
    }

    // MARK: - Item List Section

    private var itemListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Senarai Harta Karun")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
                .padding(.horizontal, 4)

            ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                treasureRow(item: item, index: index)
            }
        }
    }

    private func treasureRow(item: Activity3ViewModel.TreasureItem, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(rowStatusColor(item: item).opacity(0.15))
                    .frame(width: 44, height: 44)

                Text(item.emoji)
                    .font(.system(size: 22))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                Text(item.instruction)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            if item.isFound {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Dijumpai")
                        .font(AppTheme.captionFont)
                }
                .foregroundColor(AppTheme.forestGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppTheme.lightGreen.opacity(0.3))
                )
            } else if item.isSkipped {
                HStack(spacing: 4) {
                    Image(systemName: "forward.circle.fill")
                        .font(.system(size: 16))
                    Text("Dilangkau")
                        .font(AppTheme.captionFont)
                }
                .foregroundColor(AppTheme.secondaryText)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppTheme.secondaryText.opacity(0.1))
                )
            } else if index == viewModel.currentStep {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                    Text("Aktif")
                        .font(AppTheme.captionFont)
                }
                .foregroundColor(AppTheme.softOrange)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppTheme.softOrange.opacity(0.15))
                )
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                    Text("Menunggu")
                        .font(AppTheme.captionFont)
                }
                .foregroundColor(AppTheme.secondaryText)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppTheme.secondaryText.opacity(0.08))
                )
            }
        }
        .padding(AppTheme.compactPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(
                    item.isFound
                        ? AppTheme.lightGreen.opacity(0.1)
                        : AppTheme.cardBackground
                )
                .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .stroke(
                    item.isFound
                        ? AppTheme.forestGreen.opacity(0.2)
                        : index == viewModel.currentStep
                            ? AppTheme.softOrange.opacity(0.3)
                            : AppTheme.dividerColor.opacity(0.3),
                    lineWidth: index == viewModel.currentStep ? 2 : 1
                )
        )
        .opacity(index > viewModel.currentStep && !item.isFound && !item.isSkipped ? 0.6 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.emoji) \(item.name). Status: \(item.isFound ? "dijumpai" : item.isSkipped ? "dilangkau" : index == viewModel.currentStep ? "aktif" : "menunggu")")
    }

    private func rowStatusColor(item: Activity3ViewModel.TreasureItem) -> Color {
        if item.isFound { return AppTheme.forestGreen }
        if item.isSkipped { return AppTheme.secondaryText }
        return AppTheme.softOrange
    }

    // MARK: - Completion View

    private var completionView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                completionHeader

                completionMessageCard

                completionItemList

                completionStats

                actionButtons

                Spacer(minLength: 20)
            }
            .padding(.horizontal, AppTheme.standardPadding)
        }
    }

    private var completionHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.forestGreen, AppTheme.emerald],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 16, x: 0, y: 8)

                Text("🏆")
                    .font(.system(size: 52))
            }
            .accessibilityHidden(true)

            Text("Tahniah!")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.darkGreen)

            Text("Anda telah menyelesaikan Nature Treasure Hunt!")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.forestGreen)
                .multilineTextAlignment(.center)
        }
    }

    private var completionMessageCard: some View {
        VStack(spacing: 12) {
            Text("🌟")
                .font(.system(size: 40))
                .accessibilityHidden(true)

            Text("Anda adalah peneroka alam semula jadi yang hebat! Setiap harta karun yang anda temui menunjukkan bahawa anda sangat peka dan bijak.")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.darkGreen)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.warmBeige, AppTheme.lightGreen.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(AppTheme.lightGreen.opacity(0.3), lineWidth: 1)
        )
    }

    private var completionItemList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Harta Karun Anda")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
                .padding(.horizontal, 4)

            ForEach(viewModel.items) { item in
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                item.isFound
                                    ? AppTheme.forestGreen.opacity(0.15)
                                    : AppTheme.secondaryText.opacity(0.1)
                            )
                            .frame(width: 48, height: 48)

                        Text(item.emoji)
                            .font(.system(size: 24))
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.darkGreen)

                        Text(item.instruction)
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()

                    if item.isFound {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Dijumpai")
                                .font(AppTheme.captionFont)
                        }
                        .foregroundColor(AppTheme.forestGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(AppTheme.lightGreen.opacity(0.3))
                        )
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "forward.circle.fill")
                                .font(.system(size: 16))
                            Text("Dilangkau")
                                .font(AppTheme.captionFont)
                        }
                        .foregroundColor(AppTheme.secondaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(AppTheme.secondaryText.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal, AppTheme.compactPadding)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(item.isFound ? AppTheme.lightGreen.opacity(0.1) : AppTheme.cardBackground)
                        .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                )
            }
        }
    }

    private var completionStats: some View {
        HStack(spacing: 16) {
            statBadge(
                value: "\(viewModel.items.filter(\.isFound).count)",
                label: "Dijumpai",
                color: AppTheme.forestGreen,
                icon: "checkmark.circle.fill"
            )

            statBadge(
                value: "\(viewModel.items.filter(\.isSkipped).count)",
                label: "Dilangkau",
                color: AppTheme.secondaryText,
                icon: "forward.circle.fill"
            )

            statBadge(
                value: "\(viewModel.items.count)",
                label: "Jumlah",
                color: AppTheme.softOrange,
                icon: "list.number"
            )
        }
    }

    private func statBadge(value: String, label: String, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            .foregroundColor(color)

            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(color.opacity(0.08))
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            LargeActionButton(
                title: "Kembali ke Menu Utama",
                icon: "house.fill",
                color: AppTheme.forestGreen
            ) {
                dismiss()
            }

            LargeActionButton(
                title: "Cuba Semula",
                icon: "arrow.counterclockwise",
                color: AppTheme.softBlue
            ) {
                withAnimation(AppAnimation.smooth) {
                    viewModel.resetActivity()
                    showFeedback = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Activity3TreasureHuntView(participantID: UUID(), participantName: "Ali")
    }
}
