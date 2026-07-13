import SwiftUI
import SwiftData
import AVFoundation

struct Activity2SensoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = Activity2ViewModel()

    let participantID: UUID
    let participantName: String

    @State private var showInstruction = true
    @State private var showCamera = false
    @State private var showAudioPermissionAlert = false

    // MARK: - Station 1 (Penglihatan) local state
    @State private var selectedColour: String?
    @State private var selectedShape: String?

    // MARK: - Station 2 (Pendengaran) local state
    @State private var selectedSounds: Set<String> = []

    // MARK: - Station 3 (Sentuhan) local state
    @State private var selectedTextureItem: String?
    @State private var selectedTextureFeel: Set<String> = []

    // MARK: - Station 4 (Bau) local state
    @State private var selectedSmell: String?
    @State private var selectedReaction: String?

    // MARK: - Shared local state
    @State private var selectedEmotion: Emotion?
    @State private var showingPhotoPreview = false
    @State private var tempCapturedImage: UIImage?

    private let colourOptions = ["Hijau", "Kuning", "Coklat", "Merah", "Lain-lain"]
    private let shapeOptions = ["Bulat", "Panjang", "Lebar", "Tajam", "Lain-lain"]
    private let soundOptions: [(label: String, emoji: String)] = [
        ("Burung", "🐦"),
        ("Angin", "💨"),
        ("Serangga", "🦗"),
        ("Air", "💧"),
        ("Bunyi lain", "🔊")
    ]
    private let textureItemOptions = ["Daun", "Kulit kayu", "Batu"]
    private let textureFeelOptions = ["Licin", "Kasar", "Lembut", "Keras", "Basah", "Kering"]
    private let smellOptions = ["Bunga", "Daun beraroma", "Bau tanah", "Bau lain"]
    private let reactionOptions = ["Suka", "Tidak pasti", "Tidak suka", "Tidak mahu mencuba"]

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            if viewModel.showCompletion {
                completionView
            } else if showInstruction {
                instructionView
            } else {
                stationView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.darkGreen)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView(image: $tempCapturedImage)
                .ignoresSafeArea()
                .onDisappear {
                    if let img = tempCapturedImage {
                        viewModel.capturePhoto(img)
                        showingPhotoPreview = true
                    }
                }
        }
        .sheet(isPresented: $showingPhotoPreview) {
            if let img = viewModel.capturedImage {
                PhotoPreviewView(
                    image: img,
                    onConfirm: { showingPhotoPreview = false },
                    onRetake: {
                        showingPhotoPreview = false
                        tempCapturedImage = nil
                        showCamera = true
                    },
                    onSkip: {
                        showingPhotoPreview = false
                    }
                )
            }
        }
        .alert("Audio tidak dibenarkan", isPresented: $showAudioPermissionAlert) {
            Button("Buka Tetapan") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Sila benarkan akses mikrofon dalam tetapan untuk merakam audio.")
        }
    }

    // MARK: - Instruction View

    private var instructionView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                ProgressHeader(
                    current: viewModel.completedCount,
                    total: viewModel.stations.count,
                    showPercentage: true
                )

                VisualInstructionCard(
                    emoji: "🌉",
                    title: "Aktiviti 2: Aktiviti Sensori Alam",
                    description: "Jambatan Gantung – Merangsang perkembangan sensori melalui 4 stesen: melihat, mendengar, menyentuh, dan menghidu.",
                    stepLabel: "Langkah 1"
                )

                VStack(spacing: 16) {
                    sensoriIntroRow(emoji: "👁️", text: "Stesen 1: Melihat", colour: AppTheme.forestGreen)
                    sensoriIntroRow(emoji: "👂", text: "Stesen 2: Mendengar", colour: AppTheme.softBlue)
                    sensoriIntroRow(emoji: "🤚", text: "Stesen 3: Menyentuh", colour: AppTheme.softOrange)
                    sensoriIntroRow(emoji: "👃", text: "Stesen 4: Menghidu", colour: AppTheme.emerald)
                }
                .padding(AppTheme.standardPadding)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .fill(AppTheme.cardWhite)
                        .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
                )

                LargeActionButton(title: "Mula Aktiviti Sensori", icon: "play.fill") {
                    withAnimation(AppAnimation.smooth) {
                        showInstruction = false
                    }
                }

                LargeActionButton(
                    title: "Langkau Aktiviti",
                    icon: "forward.fill",
                    color: AppTheme.secondaryText
                ) {
                    viewModel.resetActivity()
                    dismiss()
                }
            }
            .padding(.horizontal, AppTheme.standardPadding)
            .padding(.vertical, 16)
        }
    }

    private func sensoriIntroRow(emoji: String, text: String, colour: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(colour.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(emoji)
                    .font(.system(size: 22))
            }
            .accessibilityHidden(true)

            Text(text)
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.secondaryText)
        }
    }

    // MARK: - Station View (one at a time)

    private var stationView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ProgressHeader(
                    current: viewModel.completedCount,
                    total: viewModel.stations.count,
                    showPercentage: true
                )

                stationHeader

                switch viewModel.currentStationIndex {
                case 0: station1View
                case 1: station2View
                case 2: station3View
                case 3: station4View
                default: EmptyView()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppTheme.captionFont)
                        .foregroundColor(.red)
                        .padding(.horizontal, AppTheme.compactPadding)
                }

                navigationButtons
            }
            .padding(.horizontal, AppTheme.standardPadding)
            .padding(.vertical, 16)
            .padding(.bottom, 40)
        }
    }

    private var stationHeader: some View {
        VStack(spacing: 6) {
            if let station = viewModel.currentStation {
                Text(station.emoji)
                    .font(.system(size: 48))
                    .accessibilityHidden(true)

                Text("Stesen \(station.stationNumber) daripada 4")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.forestGreen)

                Text(station.title)
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)
                    .multilineTextAlignment(.center)

                Text(station.prompt)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        VStack(spacing: 12) {
            if canConfirmCurrentStation {
                LargeActionButton(title: "Sahkan Stesen", icon: "checkmark.circle.fill") {
                    withAnimation(AppAnimation.smooth) {
                        applyCurrentStationSelection()
                        viewModel.confirmStation()
                        resetLocalState()
                        viewModel.saveCurrentStation(context: modelContext)
                    }
                }
            }

            HStack(spacing: 12) {
                if viewModel.currentStationIndex > 0 {
                    LargeActionButton(
                        title: "Sebelumnya",
                        icon: "chevron.left",
                        color: AppTheme.secondaryText
                    ) {
                        withAnimation(AppAnimation.smooth) {
                            viewModel.currentStationIndex -= 1
                            resetLocalState()
                            loadLocalStateForCurrentStation()
                        }
                    }
                }

                LargeActionButton(
                    title: "Langkau",
                    icon: "forward.fill",
                    color: AppTheme.softOrange
                ) {
                    withAnimation(AppAnimation.smooth) {
                        viewModel.skipStation()
                        resetLocalState()
                        if viewModel.isComplete {
                            viewModel.completeActivity(context: modelContext)
                        } else {
                            loadLocalStateForCurrentStation()
                        }
                    }
                }
            }
        }
    }

    private var canConfirmCurrentStation: Bool {
        switch viewModel.currentStationIndex {
        case 0: return selectedColour != nil || selectedShape != nil
        case 1: return !selectedSounds.isEmpty
        case 2: return selectedTextureItem != nil || !selectedTextureFeel.isEmpty
        case 3: return selectedSmell != nil || selectedReaction != nil
        default: return false
        }
    }

    // MARK: - Station 1: Apa Yang Saya Lihat?

    private var station1View: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pilih warna yang kamu nampak:")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    FlowLayout(spacing: 10) {
                        ForEach(colourOptions, id: \.self) { colour in
                            chipButton(
                                label: colour,
                                isSelected: selectedColour == colour,
                                colour: AppTheme.forestGreen
                            ) {
                                withAnimation(AppAnimation.fast) {
                                    selectedColour = selectedColour == colour ? nil : colour
                                }
                            }
                        }
                    }
                }
            }

            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pilih bentuk yang kamu nampak:")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    FlowLayout(spacing: 10) {
                        ForEach(shapeOptions, id: \.self) { shape in
                            chipButton(
                                label: shape,
                                isSelected: selectedShape == shape,
                                colour: AppTheme.forestGreen
                            ) {
                                withAnimation(AppAnimation.fast) {
                                    selectedShape = selectedShape == shape ? nil : shape
                                }
                            }
                        }
                    }
                }
            }

            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ambil gambar (pilihan):")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Button(action: { showCamera = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                            Text("Ambil Gambar")
                                .font(AppTheme.subheadline)
                        }
                        .foregroundColor(AppTheme.forestGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .fill(AppTheme.lightGreen.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .stroke(AppTheme.lightGreen, lineWidth: 1)
                        )
                    }

                    if viewModel.capturedImage != nil {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.forestGreen)
                            Text("Gambar telah diambil")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.forestGreen)
                        }
                    }
                }
            }

            emotionSection
        }
    }

    // MARK: - Station 2: Apa Yang Saya Dengar?

    private var station2View: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pilih bunyi yang kamu dengar:")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 12
                    ) {
                        ForEach(soundOptions, id: \.label) { sound in
                            soundCardButton(
                                label: sound.label,
                                emoji: sound.emoji,
                                isSelected: selectedSounds.contains(sound.label)
                            ) {
                                withAnimation(AppAnimation.fast) {
                                    if selectedSounds.contains(sound.label) {
                                        selectedSounds.remove(sound.label)
                                    } else {
                                        selectedSounds.insert(sound.label)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Rakam bunyi (pilihan):")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Button(action: toggleRecording) {
                        HStack(spacing: 10) {
                            Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(viewModel.isRecording ? .red : AppTheme.softBlue)

                            Text(viewModel.isRecording ? "Hentikan Rakaman" : "Mulakan Rakaman")
                                .font(AppTheme.subheadline)
                                .foregroundColor(viewModel.isRecording ? .red : AppTheme.softBlue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .fill(viewModel.isRecording ? Color.red.opacity(0.1) : AppTheme.softBlue.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .stroke(viewModel.isRecording ? Color.red.opacity(0.4) : AppTheme.softBlue.opacity(0.4), lineWidth: 1)
                        )
                    }

                    if viewModel.isRecording {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(.red)
                                .frame(width: 10, height: 10)
                                .opacity(recordingPulse ? 1 : 0.3)
                                .animation(.easeInOut(duration: 0.8).repeatForever(), value: recordingPulse)
                            Text("Merakam...")
                                .font(AppTheme.captionFont)
                                .foregroundColor(.red)
                        }
                        .onAppear { recordingPulse = true }
                        .onDisappear { recordingPulse = false }
                    }

                    if viewModel.currentStation?.audioPath != nil {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.softBlue)
                            Text("Rakaman telah disimpan")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.softBlue)
                        }
                    }
                }
            }

            emotionSection
        }
    }

    @State private var recordingPulse = false

    // MARK: - Station 3: Apa Yang Saya Sentuh?

    private var station3View: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pilih benda yang kamu sentuh:")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    FlowLayout(spacing: 10) {
                        ForEach(textureItemOptions, id: \.self) { item in
                            chipButton(
                                label: item,
                                isSelected: selectedTextureItem == item,
                                colour: AppTheme.softOrange
                            ) {
                                withAnimation(AppAnimation.fast) {
                                    selectedTextureItem = selectedTextureItem == item ? nil : item
                                }
                            }
                        }
                    }
                }
            }

            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pilih tekstur yang kamu rasa:")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    FlowLayout(spacing: 10) {
                        ForEach(textureFeelOptions, id: \.self) { feel in
                            chipButton(
                                label: feel,
                                isSelected: selectedTextureFeel.contains(feel),
                                colour: AppTheme.softOrange
                            ) {
                                withAnimation(AppAnimation.fast) {
                                    if selectedTextureFeel.contains(feel) {
                                        selectedTextureFeel.remove(feel)
                                    } else {
                                        selectedTextureFeel.insert(feel)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ambil gambar (pilihan):")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Button(action: { showCamera = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                            Text("Ambil Gambar")
                                .font(AppTheme.subheadline)
                        }
                        .foregroundColor(AppTheme.softOrange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .fill(AppTheme.softOrange.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .stroke(AppTheme.softOrange.opacity(0.4), lineWidth: 1)
                        )
                    }

                    if viewModel.capturedImage != nil {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.softOrange)
                            Text("Gambar telah diambil")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.softOrange)
                        }
                    }
                }
            }

            emotionSection
        }
    }

    // MARK: - Station 4: Apa Yang Saya Hidu?

    private var station4View: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pilih bau yang kamu hidu:")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    FlowLayout(spacing: 10) {
                        ForEach(smellOptions, id: \.self) { smell in
                            chipButton(
                                label: smell,
                                isSelected: selectedSmell == smell,
                                colour: AppTheme.emerald
                            ) {
                                withAnimation(AppAnimation.fast) {
                                    selectedSmell = selectedSmell == smell ? nil : smell
                                }
                            }
                        }
                    }
                }
            }

            sectionCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bagaimana reaksi kamu?")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    FlowLayout(spacing: 10) {
                        ForEach(reactionOptions, id: \.self) { reaction in
                            chipButton(
                                label: reaction,
                                isSelected: selectedReaction == reaction,
                                colour: AppTheme.emerald
                            ) {
                                withAnimation(AppAnimation.fast) {
                                    selectedReaction = selectedReaction == reaction ? nil : reaction
                                }
                            }
                        }
                    }
                }
            }

            emotionSection
        }
    }

    // MARK: - Emotion Section

    private var emotionSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bagaimana perasaan kamu?")
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
    }

    // MARK: - Completion View

    private var completionView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer(minLength: 40)

                ZStack {
                    Circle()
                        .fill(AppTheme.lightGreen.opacity(0.3))
                        .frame(width: 100, height: 100)

                    Text("🎉")
                        .font(.system(size: 52))
                }

                Text("Tahniah!")
                    .font(AppTheme.largeTitle)
                    .foregroundColor(AppTheme.darkGreen)

                Text("Aktiviti Sensori selesai.")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.forestGreen)

                Text("Kamu telah melawat semua 4 stesen sensori. Bagus job!")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.standardPadding)

                stationSummary

                LargeActionButton(title: "Kembali ke Menu Utama", icon: "house.fill") {
                    viewModel.completeActivity(context: modelContext)
                    dismiss()
                }

                LargeActionButton(
                    title: "Ulang Aktiviti",
                    icon: "arrow.counterclockwise",
                    color: AppTheme.secondaryText
                ) {
                    viewModel.resetActivity()
                    resetLocalState()
                    withAnimation(AppAnimation.smooth) {
                        showInstruction = true
                    }
                }
            }
            .padding(.horizontal, AppTheme.standardPadding)
            .padding(.bottom, 40)
        }
    }

    private var stationSummary: some View {
        VStack(spacing: 12) {
            Text("Ringkasan Stesen")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            ForEach(viewModel.stations) { station in
                HStack(spacing: 12) {
                    Text(station.emoji)
                        .font(.system(size: 22))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(station.title)
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.darkGreen)

                        if station.isSkipped {
                            Text("Dilangkau")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.secondaryText)
                        } else if let value = station.selectedValue {
                            Text(value)
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.forestGreen)
                        }
                    }

                    Spacer()

                    if station.isSkipped {
                        Image(systemName: "forward.fill")
                            .foregroundColor(AppTheme.secondaryText)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.forestGreen)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(AppTheme.cardWhite)
                        .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                )
            }
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardWhite)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    // MARK: - Helpers

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(AppTheme.standardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardWhite)
                    .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
            )
    }

    private func chipButton(label: String, isSelected: Bool, colour: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppTheme.subheadline)
                .foregroundColor(isSelected ? .white : colour)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(isSelected ? colour : colour.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? colour : colour.opacity(0.3), lineWidth: 1)
                )
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func soundCardButton(label: String, emoji: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 32))

                Text(label)
                    .font(AppTheme.subheadline)
                    .foregroundColor(isSelected ? .white : AppTheme.darkGreen)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 90)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(isSelected ? AppTheme.softBlue : AppTheme.cardWhite)
                    .shadow(
                        color: isSelected ? AppTheme.softBlue.opacity(0.25) : AppTheme.cardShadowColor,
                        radius: isSelected ? 8 : AppTheme.cardShadowRadius,
                        x: 0, y: isSelected ? 2 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .stroke(isSelected ? AppTheme.softBlue : AppTheme.dividerColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func toggleRecording() {
        if viewModel.isRecording {
            viewModel.stopRecording()
        } else {
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            switch status {
            case .authorized:
                viewModel.startRecording()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: audioMediaType) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            viewModel.startRecording()
                        } else {
                            showAudioPermissionAlert = true
                        }
                    }
                }
            case .denied, .restricted:
                showAudioPermissionAlert = true
            @unknown default:
                showAudioPermissionAlert = true
            }
        }
    }

    private var audioMediaType: AVMediaType {
        .audio
    }

    private func applyCurrentStationSelection() {
        let value: String
        switch viewModel.currentStationIndex {
        case 0:
            var parts: [String] = []
            if let c = selectedColour { parts.append("Warna: \(c)") }
            if let s = selectedShape { parts.append("Bentuk: \(s)") }
            value = parts.joined(separator: ", ")
        case 1:
            value = selectedSounds.sorted().joined(separator: ", ")
        case 2:
            var parts: [String] = []
            if let item = selectedTextureItem { parts.append("Benda: \(item)") }
            if !selectedTextureFeel.isEmpty { parts.append("Tekstur: \(selectedTextureFeel.sorted().joined(separator: ", "))") }
            value = parts.joined(separator: ", ")
        case 3:
            var parts: [String] = []
            if let s = selectedSmell { parts.append("Bau: \(s)") }
            if let r = selectedReaction { parts.append("Reaksi: \(r)") }
            value = parts.joined(separator: ", ")
        default:
            value = ""
        }

        viewModel.selectValue(value)
        if let emotion = selectedEmotion {
            viewModel.selectEmotion(emotion.rawValue)
        }
    }

    private func resetLocalState() {
        selectedColour = nil
        selectedShape = nil
        selectedSounds = []
        selectedTextureItem = nil
        selectedTextureFeel = []
        selectedSmell = nil
        selectedReaction = nil
        selectedEmotion = nil
        tempCapturedImage = nil
    }

    private func loadLocalStateForCurrentStation() {
        guard let station = viewModel.currentStation else { return }

        if let emotionName = station.emotion {
            selectedEmotion = Emotion(rawValue: emotionName)
        } else {
            selectedEmotion = nil
        }

        guard let value = station.selectedValue, !value.isEmpty else {
            return
        }

        switch viewModel.currentStationIndex {
        case 0:
            for part in value.components(separatedBy: ", ") {
                let kv = part.components(separatedBy: ": ")
                guard kv.count == 2 else { continue }
                if kv[0] == "Warna" { selectedColour = kv[1] }
                if kv[0] == "Bentuk" { selectedShape = kv[1] }
            }
        case 1:
            selectedSounds = Set(value.components(separatedBy: ", "))
        case 2:
            for part in value.components(separatedBy: ", ") {
                let kv = part.components(separatedBy: ": ")
                guard kv.count == 2 else { continue }
                if kv[0] == "Benda" { selectedTextureItem = kv[1] }
                if kv[0] == "Tekstur" { selectedTextureFeel = Set(kv[1].components(separatedBy: ", ")) }
            }
        case 3:
            for part in value.components(separatedBy: ", ") {
                let kv = part.components(separatedBy: ": ")
                guard kv.count == 2 else { continue }
                if kv[0] == "Bau" { selectedSmell = kv[1] }
                if kv[0] == "Reaksi" { selectedReaction = kv[1] }
            }
        default:
            break
        }
    }
}

#Preview {
    NavigationStack {
        Activity2SensoryView(participantID: UUID(), participantName: "Ali")
    }
    .modelContainer(for: ActivitySession.self, inMemory: true)
}
