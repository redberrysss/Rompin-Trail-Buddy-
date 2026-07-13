import SwiftUI
import SwiftData

struct Activity1NatureWalkView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = Activity1ViewModel()

    let participantID: UUID
    let participantName: String

    @State private var instructionStep = 0
    @State private var showCamera = false
    @State private var showManualPicker = false

    private let instructionEmojis = ["🚶", "🌿", "📸", "📋"]
    private let instructionTitles = [
        "Berjalan dalam Kumpulan",
        "Perhatikan Sekitar",
        "Ambil Gambar",
        "Lengkapkan Pemerhatian"
    ]
    private let instructionDescriptions = [
        "Peserta berjalan dalam kumpulan kecil.",
        "Fasilitator menunjukkan tumbuhan dan haiwan yang dijumpai.",
        "Peserta mengambil gambar atau menandakan objek yang dilihat.",
        "Peserta melengkapkan lembaran pemerhatian digital."
    ]

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            if viewModel.showCompletion {
                completionView
            } else if instructionStep < instructionEmojis.count {
                instructionPhaseView
            } else {
                observationPhaseView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Kembali")
                    }
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(image: $viewModel.capturedImage)
                .onDisappear {
                    if viewModel.capturedImage != nil {
                        Task { await viewModel.runDetection() }
                    }
                }
        }
        .sheet(isPresented: $showManualPicker) {
            manualSelectionSheet
        }
    }

    // MARK: - Instruction Phase

    private var instructionPhaseView: some View {
        VStack(spacing: 24) {
            headerSection

            Spacer()

            VisualInstructionCard(
                emoji: instructionEmojis[instructionStep],
                title: instructionTitles[instructionStep],
                description: instructionDescriptions[instructionStep],
                stepLabel: "Langkah \(instructionStep + 1) daripada \(instructionEmojis.count)"
            )
            .padding(.horizontal, AppTheme.standardPadding)

            stepDots

            Spacer()

            instructionButtons
        }
        .padding(.bottom, AppTheme.standardPadding)
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("🌿")
                .font(.system(size: 44))
                .accessibilityHidden(true)

            Text("Aktiviti 1: Nature Walk – Jelajah Hutan")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)
                .multilineTextAlignment(.center)

            Text("Meningkatkan kemahiran pemerhatian dan eksplorasi.")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppTheme.standardPadding)
        .padding(.top, 12)
    }

    private var stepDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<instructionEmojis.count, id: \.self) { index in
                Circle()
                    .fill(index == instructionStep ? AppTheme.forestGreen : AppTheme.lightGreen.opacity(0.5))
                    .frame(width: 12, height: 12)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Langkah \(instructionStep + 1) daripada \(instructionEmojis.count)")
    }

    private var instructionButtons: some View {
        HStack(spacing: 16) {
            if instructionStep > 0 {
                LargeActionButton(
                    title: "Sebelumnya",
                    icon: "chevron.left",
                    color: AppTheme.secondaryText
                ) {
                    withAnimation(AppAnimation.smooth) {
                        instructionStep -= 1
                    }
                }
            }

            if instructionStep < instructionEmojis.count - 1 {
                LargeActionButton(
                    title: "Seterusnya",
                    icon: "chevron.right",
                    color: AppTheme.forestGreen
                ) {
                    withAnimation(AppAnimation.smooth) {
                        instructionStep += 1
                    }
                }
            } else {
                LargeActionButton(
                    title: "Mulakan Pemerhatian",
                    icon: "leaf.fill",
                    color: AppTheme.emerald
                ) {
                    withAnimation(AppAnimation.smooth) {
                        instructionStep += 1
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.standardPadding)
    }

    // MARK: - Observation Phase

    private var observationPhaseView: some View {
        VStack(spacing: 0) {
            ProgressHeader(
                current: viewModel.completedCount,
                total: viewModel.items.count,
                showPercentage: true
            )
            .padding(.horizontal, AppTheme.standardPadding)
            .padding(.top, 12)

            if let item = viewModel.currentItem {
                observationItemView(item: item)
            }
        }
    }

    private func observationItemView(item: Activity1ViewModel.ObservationItem) -> some View {
        VStack(spacing: 20) {
            Spacer()

            currentItemCard(item: item)

            if let image = viewModel.capturedImage {
                capturedImageSection(image: image, item: item)
            } else if item.isCompleted || item.isSkipped {
                completedItemSection
            } else {
                captureButtonSection
            }

            if let error = viewModel.errorMessage {
                errorBanner(error)
            }

            if viewModel.isProcessing {
                processingIndicator
            }

            navigationButtons
        }
        .padding(.horizontal, AppTheme.standardPadding)
        .padding(.bottom, AppTheme.standardPadding)
    }

    private func currentItemCard(item: Activity1ViewModel.ObservationItem) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(statusColor(for: item).opacity(0.15))
                    .frame(width: 80, height: 80)

                Text(item.emoji)
                    .font(.system(size: 44))
            }
            .accessibilityHidden(true)

            Text(item.name)
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)

            if let label = item.detectedLabel, let conf = item.confidence {
                detectionResultLabel(label: label, confidence: conf)
            } else if item.isSkipped {
                Text("Dilangkau")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.secondaryText)
            } else {
                Text("Ambil gambar objek ini")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardWhite)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(statusColor(for: item).opacity(0.3), lineWidth: 1.5)
        )
    }

    private func detectionResultLabel(label: String, confidence: Double) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.forestGreen)
                Text("Dikesan: \(label)")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)
            }

            Text("Keyakinan: \(Int(confidence * 100))%")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppTheme.lightGreen.opacity(0.25))
        )
    }

    private func capturedImageSection(image: UIImage, item: Activity1ViewModel.ObservationItem) -> some View {
        PhotoPreviewView(
            image: image,
            onConfirm: {
                viewModel.confirmDetection()
            },
            onRetake: {
                viewModel.retakePhoto()
            },
            onSkip: {
                viewModel.skipItem()
            }
        )
        .transition(.opacity)
    }

    private var completedItemSection: some View {
        VStack(spacing: 16) {
            if let item = viewModel.currentItem {
                if item.isCompleted, let label = item.detectedLabel {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppTheme.emerald)

                        Text("Selesai: \(label)")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.darkGreen)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(AppTheme.emerald.opacity(0.1))
                    )
                }
            }
        }
        .padding(.horizontal, AppTheme.compactPadding)
    }

    private var captureButtonSection: some View {
        VStack(spacing: 12) {
            LargeActionButton(
                title: "Ambil Gambar",
                icon: "camera.fill",
                color: AppTheme.forestGreen
            ) {
                showCamera = true
            }

            LargeActionButton(
                title: "Pilih Secara Manual",
                icon: "hand.tap.fill",
                color: AppTheme.softBlue
            ) {
                showManualPicker = true
            }

            OCRToggleButton

            LargeActionButton(
                title: "Langkau Item Ini",
                icon: "forward.fill",
                color: AppTheme.secondaryText
            ) {
                viewModel.skipItem()
            }
        }
    }

    private var OCRToggleButton: some View {
        Button {
            viewModel.isOCRMode.toggle()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: viewModel.isOCRMode ? "text.viewfinder" : "doc.text.viewfinder")
                    .font(.system(size: 18))

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.isOCRMode ? "Mod OCR: Aktif" : "Mod OCR: Mati")
                        .font(AppTheme.subheadline)
                    Text("Kesan teks pada objek")
                        .font(AppTheme.captionFont)
                }

                Spacer()

                Capsule()
                    .fill(viewModel.isOCRMode ? AppTheme.emerald : AppTheme.lightGreen.opacity(0.5))
                    .frame(width: 50, height: 28)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 22, height: 22)
                            .offset(x: viewModel.isOCRMode ? 11 : -11)
                    )
            }
            .foregroundColor(AppTheme.darkGreen)
            .padding(AppTheme.compactPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(AppTheme.cardWhite)
                    .shadow(color: AppTheme.cardShadowColor, radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .stroke(AppTheme.lightGreen.opacity(0.4), lineWidth: 1)
            )
        }
        .accessibilityLabel("Mod OCR")
        .accessibilityValue(viewModel.isOCRMode ? "Aktif" : "Mati")
        .accessibilityHint("Taip untuk menukar mod pengesanan")
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppTheme.softOrange)

            Text(message)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.darkGreen)

            Spacer()

            Button {
                viewModel.errorMessage = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .padding(AppTheme.compactPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.softOrange.opacity(0.12))
        )
    }

    private var processingIndicator: some View {
        VStack(spacing: 10) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(AppTheme.forestGreen)

            Text("Menganalisis gambar...")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentStep > 0 {
                LargeActionButton(
                    title: "Sebelumnya",
                    icon: "chevron.left",
                    color: AppTheme.secondaryText
                ) {
                    viewModel.currentStep -= 1
                    viewModel.retakePhoto()
                }
            }

            if viewModel.currentStep < viewModel.items.count - 1 {
                LargeActionButton(
                    title: "Seterusnya",
                    icon: "chevron.right",
                    color: AppTheme.forestGreen
                ) {
                    viewModel.skipItem()
                }
            }
        }
    }

    // MARK: - Manual Selection Sheet

    private var manualSelectionSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Pilih Objek")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)
                    .padding(.top, 20)

                Text("Pilih objek yang paling hampir dengan apa yang anda nampak.")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.standardPadding)

                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 140), spacing: 16)
                ], spacing: 16) {
                    ForEach(viewModel.items, id: \.id) { item in
                        Button {
                            viewModel.manuallySelect(itemName: item.name)
                            showManualPicker = false
                        } label: {
                            VStack(spacing: 10) {
                                Text(item.emoji)
                                    .font(.system(size: 40))

                                Text(item.name)
                                    .font(AppTheme.subheadline)
                                    .foregroundColor(AppTheme.darkGreen)

                                if item.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.emerald)
                                } else if item.isSkipped {
                                    Image(systemName: "forward.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                                    .fill(
                                        item.isCompleted
                                            ? AppTheme.emerald.opacity(0.1)
                                            : AppTheme.cardWhite
                                    )
                                    .shadow(color: AppTheme.cardShadowColor, radius: 6, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                                    .stroke(
                                        item.isCompleted ? AppTheme.emerald.opacity(0.4) : AppTheme.dividerColor,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .disabled(item.isCompleted)
                        .opacity(item.isCompleted ? 0.5 : 1.0)
                    }
                }
                .padding(.horizontal, AppTheme.standardPadding)

                Spacer()
            }
            .background(AppTheme.backgroundGradient)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        showManualPicker = false
                    }
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
    }

    // MARK: - Completion Screen

    private var completionView: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.emerald, AppTheme.forestGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: AppTheme.emerald.opacity(0.3), radius: 16, x: 0, y: 8)

                Text("🎉")
                    .font(.system(size: 56))
            }
            .accessibilityHidden(true)

            Text("Tahniah!")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.darkGreen)

            Text("Anda telah lengkapkan Nature Walk!")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            completionSummary

            Spacer()

            VStack(spacing: 14) {
                LargeActionButton(
                    title: "Simpan & Selesai",
                    icon: "checkmark.circle.fill",
                    color: AppTheme.forestGreen
                ) {
                    viewModel.completeActivity(context: modelContext)
                    dismiss()
                }

                LargeActionButton(
                    title: "Kembali ke Laman Utama",
                    icon: "house.fill",
                    color: AppTheme.emerald
                ) {
                    dismiss()
                }
            }
            .padding(.horizontal, AppTheme.standardPadding)
            .padding(.bottom, AppTheme.standardPadding)
        }
    }

    private var completionSummary: some View {
        VStack(spacing: 12) {
            HStack(spacing: 24) {
                completionStat(
                    count: viewModel.items.filter { $0.isCompleted }.count,
                    label: "Dikesan",
                    color: AppTheme.emerald
                )

                completionStat(
                    count: viewModel.items.filter { $0.isSkipped }.count,
                    label: "Dilangkau",
                    color: AppTheme.secondaryText
                )

                completionStat(
                    count: viewModel.items.count,
                    label: "Jumlah",
                    color: AppTheme.forestGreen
                )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.items, id: \.id) { item in
                        VStack(spacing: 6) {
                            Text(item.emoji)
                                .font(.system(size: 28))

                            Text(item.name)
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.darkGreen)

                            if item.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.emerald)
                            } else {
                                Image(systemName: "forward.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }
                        .frame(width: 80)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .fill(AppTheme.cardWhite)
                                .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                        )
                    }
                }
                .padding(.horizontal, AppTheme.standardPadding)
            }
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardWhite)
                .shadow(color: AppTheme.cardShadowColor, radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, AppTheme.standardPadding)
    }

    private func completionStat(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(minWidth: 60)
    }

    // MARK: - Helpers

    private func statusColor(for item: Activity1ViewModel.ObservationItem) -> Color {
        if item.isCompleted { return AppTheme.emerald }
        if item.isSkipped { return AppTheme.secondaryText }
        return AppTheme.softOrange
    }
}

#Preview {
    NavigationStack {
        Activity1NatureWalkView(participantID: UUID(), participantName: "Ali")
    }
    .modelContainer(for: ActivitySession.self, inMemory: true)
}
