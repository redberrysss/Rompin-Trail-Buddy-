import SwiftUI
import SwiftData

struct Activity4NatureArtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = Activity4ViewModel()
    @State private var showModePicker = true
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showPhotoPreview = false

    let participantID: UUID
    let participantName: String

    var body: some View {
        VStack(spacing: 0) {
            if showModePicker {
                modePickerView
            } else if viewModel.showPhysicalMode {
                physicalArtView
            } else {
                digitalArtView
            }
        }
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Seni Alam Semula Jadi")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startSession(participantID: participantID, context: modelContext)
        }
        .onChange(of: viewModel.progress) { _, newValue in
            if newValue >= 1.0 {
                viewModel.completeActivity(context: modelContext)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(image: $capturedImage)
        }
        .onChange(of: capturedImage) { _, newImage in
            guard newImage != nil else { return }
            showPhotoPreview = true
        }
        .overlay {
            if viewModel.progress >= 1.0 && !savedArtworksEmpty {
                completionOverlay
            }
            if viewModel.isProcessing {
                processingOverlay
            }
        }
        .alert("Perhatian", isPresented: .init(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var savedArtworksEmpty: Bool {
        viewModel.savedArtworks.isEmpty
    }

    // MARK: - Mode Picker

    private var modePickerView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                headerSection

                Text("Aktiviti 4: Seni Alam Semula Jadi")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)
                    .multilineTextAlignment(.center)

                Text("Menggalakkan kreativiti dan motor halus.")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    LargeActionButton(
                        title: "Digital - Kolaj Alam",
                        icon: "rectangle.on.rectangle"
                    ) {
                        withAnimation(.smooth) {
                            viewModel.showPhysicalMode = false
                            showModePicker = false
                        }
                    }

                    LargeActionButton(
                        title: "Fizikal - Hasil Kraf",
                        icon: "camera.fill",
                        color: AppTheme.softBlue
                    ) {
                        withAnimation(.smooth) {
                            viewModel.showPhysicalMode = true
                            showModePicker = false
                        }
                    }
                }
                .padding(.horizontal, AppTheme.standardPadding)
            }
            .padding(.vertical, AppTheme.standardPadding)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.3))
                    .frame(width: 72, height: 72)
                Text("🎨")
                    .font(.system(size: 36))
            }
            Text("Pilih Mod Seni")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Digital Art View

    private var digitalArtView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ProgressHeader(current: viewModel.savedArtworks.isEmpty ? 0 : 1, total: 1, showPercentage: true)
                    .padding(.horizontal, AppTheme.standardPadding)
                    .padding(.top, 8)

                gallerySection
                canvasSection
                backgroundSelector
                stickerSection
                titleSection
                canvasActions
                savedArtworksSection
            }
            .padding(.bottom, 40)
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
    }

    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Galeri Penemuan Saya")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
                Text("\(viewModel.selectedImages.count) dipilih")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(.horizontal, AppTheme.standardPadding)

            if viewModel.galleryItems.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.secondaryText)
                        Text("Tiada gambar. Selesaikan aktiviti 1-3.")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .fill(AppTheme.cardBackground)
                        .padding(.horizontal, AppTheme.standardPadding)
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.galleryItems) { item in
                            galleryThumbnail(item)
                        }
                    }
                    .padding(.horizontal, AppTheme.standardPadding)
                }
            }
        }
    }

    private func galleryThumbnail(_ item: Activity4ViewModel.GalleryItem) -> some View {
        let isSelected = viewModel.selectedImages.contains(where: { $0.id == item.id })
        let uiImage = ImageStorageService.shared.loadImage(at: item.imagePath)

        return Button {
            if isSelected {
                viewModel.deselectPhoto(item)
            } else {
                viewModel.selectPhotoFromGallery(item)
            }
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    if let img = uiImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.lightGreen.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: "leaf")
                                    .foregroundColor(AppTheme.forestGreen)
                            }
                    }

                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(AppTheme.forestGreen)
                                .frame(width: 24, height: 24)
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: 6, y: -6)
                    }
                }

                Text(item.objectName)
                    .font(AppTheme.smallCaption)
                    .foregroundColor(AppTheme.darkGreen)
                    .lineLimit(1)

                Text("A\(item.activityNumber)")
                    .font(AppTheme.smallCaption)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .frame(width: 88)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? AppTheme.lightGreen.opacity(0.3) : AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
            )
            .overlay(
                isSelected ?
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.forestGreen, lineWidth: 2) : nil
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.objectName). \(isSelected ? "Dipilih" : "Tekan untuk pilih")")
    }

    private var canvasSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kanvas")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
                .padding(.horizontal, AppTheme.standardPadding)

            ZStack {
                canvasBackground
                ForEach(viewModel.canvasImages) { canvasImg in
                    canvasItemView(canvasImg)
                }
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .stroke(AppTheme.dividerColor, lineWidth: 1)
            )
            .shadow(color: AppTheme.cardShadowColor, radius: 6, x: 0, y: 3)
            .padding(.horizontal, AppTheme.standardPadding)

            if viewModel.canvasImages.isEmpty {
                Text("Pilih gambar dari galeri atau tambah sticker")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var canvasBackground: some View {
        Group {
            switch viewModel.selectedBackground {
            case "Putih":
                Color.white
            case "Hijau Daun":
                Color(red: 0.36, green: 0.70, blue: 0.36)
            case "Biru Langit":
                Color(red: 0.53, green: 0.81, blue: 0.92)
            case "Coklat Tanah":
                Color(red: 0.65, green: 0.46, blue: 0.30)
            default:
                Color.white
            }
        }
    }

    private func canvasItemView(_ canvasImg: Activity4ViewModel.CanvasImage) -> some View {
        let uiImage = ImageStorageService.shared.loadImage(at: canvasImg.imagePath)

        return Group {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100 * canvasImg.scale, height: 100 * canvasImg.scale)
                    .rotationEffect(canvasImg.rotation)
                    .offset(canvasImg.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.updateImagePosition(canvasImg.id, position: CGSize(
                                    width: canvasImg.position.width + value.translation.width * 0.05,
                                    height: canvasImg.position.height + value.translation.height * 0.05
                                ))
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                viewModel.resizeImage(canvasImg.id, scale: canvasImg.scale * value)
                            }
                    )
                    .gesture(
                        RotationGesture()
                            .onChanged { value in
                                viewModel.rotateImage(canvasImg.id, angle: canvasImg.rotation + value)
                            }
                    )
                    .onTapGesture {
                        viewModel.bringToFront(canvasImg.id)
                    }
                    .zIndex(Double(canvasImg.zIndex))
            }
        }
    }

    private var backgroundSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Latar Belakang")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
                .padding(.horizontal, AppTheme.standardPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.backgroundOptions, id: \.name) { option in
                        Button {
                            viewModel.setBackground(option.name)
                        } label: {
                            VStack(spacing: 4) {
                                Text(option.color)
                                    .font(.system(size: 32))
                                Text(option.name)
                                    .font(AppTheme.smallCaption)
                                    .foregroundColor(AppTheme.darkGreen)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.selectedBackground == option.name ? AppTheme.lightGreen.opacity(0.3) : AppTheme.cardBackground)
                            )
                            .overlay(
                                viewModel.selectedBackground == option.name ?
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.forestGreen, lineWidth: 2) : nil
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.standardPadding)
            }
        }
    }

    private var stickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stiker")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
                .padding(.horizontal, AppTheme.standardPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.stickerOptions, id: \.name) { sticker in
                        Button {
                            viewModel.addSticker(emoji: sticker.emoji)
                        } label: {
                            VStack(spacing: 4) {
                                Text(sticker.emoji)
                                    .font(.system(size: 36))
                                Text(sticker.name)
                                    .font(AppTheme.smallCaption)
                                    .foregroundColor(AppTheme.darkGreen)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.cardBackground)
                                    .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.standardPadding)
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tajuk Karya")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
                .padding(.horizontal, AppTheme.standardPadding)

            TextField("Masukkan tajuk...", text: $viewModel.title)
                .font(AppTheme.bodyFont)
                .padding(AppTheme.compactPadding)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(AppTheme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .stroke(AppTheme.dividerColor, lineWidth: 1)
                        )
                )
                .padding(.horizontal, AppTheme.standardPadding)
        }
    }

    private var canvasActions: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: viewModel.undo) {
                    Label("Buat Asal", systemImage: "arrow.uturn.backward")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.darkGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .fill(AppTheme.cardBackground)
                                .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                        )
                }
                .disabled(viewModel.canvasImages.isEmpty)
                .opacity(viewModel.canvasImages.isEmpty ? 0.4 : 1)
                .buttonStyle(.plain)

                Button(action: viewModel.resetCanvas) {
                    Label("Set Semula", systemImage: "trash")
                        .font(AppTheme.captionFont)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .fill(AppTheme.cardBackground)
                                .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                        )
                }
                .disabled(viewModel.canvasImages.isEmpty)
                .opacity(viewModel.canvasImages.isEmpty ? 0.4 : 1)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.standardPadding)

            LargeActionButton(
                title: "Simpan Karya Seni",
                icon: "square.and.arrow.down",
                isDisabled: viewModel.canvasImages.isEmpty || viewModel.isProcessing
            ) {
                viewModel.saveArtwork(context: modelContext)
            }
            .padding(.horizontal, AppTheme.standardPadding)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.smooth) { showModePicker = true }
            } label: {
                Label("Tukar Mod", systemImage: "arrow.left")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.forestGreen)
            }

            Spacer()

            Text("\(viewModel.canvasImages.count) elemen")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(.horizontal, AppTheme.standardPadding)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.glassBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: 8, x: 0, y: -4)
        )
        .padding(.horizontal, AppTheme.standardPadding)
        .padding(.bottom, 8)
    }

    // MARK: - Physical Art View

    private var physicalArtView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ProgressHeader(current: viewModel.savedArtworks.contains(where: { $0.artworkType == "physical" }) ? 1 : 0, total: 1, showPercentage: true)
                    .padding(.horizontal, AppTheme.standardPadding)
                    .padding(.top, 8)

                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.softBlue.opacity(0.3))
                            .frame(width: 56, height: 56)
                        Text("🖐️")
                            .font(.system(size: 28))
                    }

                    Text("Seni Fizikal")
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.darkGreen)

                    Text("Kumpul bahan semula jadi dan hasilkan kraf!")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppTheme.standardPadding)

                VStack(spacing: 12) {
                    VisualInstructionCard(
                        emoji: "🌿",
                        title: "Kumpul Bahan",
                        description: "Kumpulkan daun, ranting, batu, atau bunga.",
                        stepLabel: "Langkah 1"
                    )

                    VisualInstructionCard(
                        emoji: "📄",
                        title: "Susun Bahan",
                        description: "Susun bahan di atas kertas A4.",
                        stepLabel: "Langkah 2"
                    )

                    VisualInstructionCard(
                        emoji: "🫙",
                        title: "Gam atau Tape",
                        description: "Gunakan gam atau salotape untuk lekatkan bahan.",
                        stepLabel: "Langkah 3"
                    )

                    VisualInstructionCard(
                        emoji: "📸",
                        title: "Ambil Gambar",
                        description: "Ambil gambar hasil karya anda.",
                        stepLabel: "Langkah 4"
                    )

                    VisualInstructionCard(
                        emoji: "💾",
                        title: "Simpan",
                        description: "Simpan gambar karya seni anda.",
                        stepLabel: "Langkah 5"
                    )
                }
                .padding(.horizontal, AppTheme.standardPadding)

                if let previewImage = capturedImage, showPhotoPreview {
                    PhotoPreviewView(
                        image: previewImage,
                        onConfirm: {
                            viewModel.capturePhysicalArtwork(previewImage, context: modelContext)
                            capturedImage = nil
                            showPhotoPreview = false
                        },
                        onRetake: {
                            capturedImage = nil
                            showPhotoPreview = false
                            showCamera = true
                        },
                        onSkip: nil
                    )
                    .padding(.horizontal, AppTheme.standardPadding)
                } else {
                    LargeActionButton(
                        title: "Ambil Gambar Hasil Karya",
                        icon: "camera.fill",
                        color: AppTheme.softBlue
                    ) {
                        showCamera = true
                    }
                    .padding(.horizontal, AppTheme.standardPadding)
                }

                savedArtworksSection

                Button {
                    withAnimation(.smooth) { showModePicker = true }
                } label: {
                    Label("Kembali ke Pilihan Mod", systemImage: "arrow.left")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.forestGreen)
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Saved Artworks

    private var savedArtworksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hasil Karya Disimpan")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
                .padding(.horizontal, AppTheme.standardPadding)

            if viewModel.savedArtworks.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.secondaryText)
                        Text("Belum ada karya seni.")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .fill(AppTheme.cardBackground)
                        .padding(.horizontal, AppTheme.standardPadding)
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.savedArtworks) { artwork in
                            savedArtworkCard(artwork)
                        }
                    }
                    .padding(.horizontal, AppTheme.standardPadding)
                }
            }
        }
    }

    @ViewBuilder
    private func savedArtworkCard(_ artwork: ArtworkRecord) -> some View {
        let uiImage = ImageStorageService.shared.loadImage(at: artwork.artworkImagePath)

        VStack(alignment: .leading, spacing: 6) {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.lightGreen.opacity(0.3))
                    .frame(width: 140, height: 110)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(AppTheme.forestGreen)
                    }
            }

            Text(artwork.title)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.darkGreen)
                .lineLimit(1)

            HStack(spacing: 4) {
                Image(systemName: artwork.artworkType == "digital" ? "rectangle.on.rectangle" : "camera.fill")
                    .font(.system(size: 10))
                Text(artwork.artworkType == "digital" ? "Digital" : "Fizikal")
                    .font(AppTheme.smallCaption)
            }
            .foregroundColor(AppTheme.secondaryText)
        }
        .frame(width: 140)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: 6, x: 0, y: 3)
        )
        .accessibilityLabel("Karya: \(artwork.title). \(artwork.artworkType == "digital" ? "Digital" : "Fizikal")")
    }

    // MARK: - Overlays

    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(AppTheme.forestGreen)
                    .scaleEffect(1.5)
                Text("Memproses...")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppTheme.lightGreen.opacity(0.3))
                        .frame(width: 80, height: 80)
                    Text("🎨")
                        .font(.system(size: 40))
                }

                Text("Tahniah!")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)

                Text("Karya seni anda telah berjaya disimpan!")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)

                HStack(spacing: 14) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Selesai", systemImage: "checkmark.circle.fill")
                            .font(AppTheme.largeButtonFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                    .fill(AppTheme.primaryGradient)
                                    .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }

                    Button {
                        viewModel.resetCanvas()
                        viewModel.progress = 0
                    } label: {
                        Label("Buat Lagi", systemImage: "arrow.clockwise")
                            .font(AppTheme.largeButtonFont)
                            .foregroundColor(AppTheme.forestGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                    .fill(AppTheme.lightGreen.opacity(0.3))
                                    .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
        }
    }
}
