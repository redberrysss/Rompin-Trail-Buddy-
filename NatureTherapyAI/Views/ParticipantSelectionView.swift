import SwiftUI
import SwiftData

struct ParticipantSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var participants: [Participant] = []
    @State private var showAddParticipant = false
    @State private var newParticipantName = ""
    @State private var selectedAvatar = "🌟"
    @State private var showFacilitatorMode = false
    @State private var navigateToHome = false
    @State private var selectedParticipant: Participant?
    @State private var participantToDelete: Participant?
    @State private var showDeleteConfirmation = false

    private let avatarOptions = ["🌟", "🦁", "🐯", "🐰", "🐼", "🦊", "🐸", "🐵", "🦋", "🌸", "🌿", "🍄"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection

                    if participants.isEmpty {
                        emptyStateView
                    } else {
                        participantListSection
                    }

                    addParticipantButton
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 40)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFacilitatorMode = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill.gearshape")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Fasilitator")
                                .font(AppTheme.captionFont)
                        }
                        .foregroundColor(AppTheme.forestGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(AppTheme.lightGreen.opacity(0.3))
                        )
                    }
                }
            }
            .onAppear {
                loadParticipants()
            }
            .sheet(isPresented: $showAddParticipant) {
                addParticipantSheet
            }
            .sheet(isPresented: $showFacilitatorMode) {
                facilitatorModeSheet
            }
            .navigationDestination(isPresented: $navigateToHome) {
                if let participant = selectedParticipant {
                    HomeDashboardView(participantID: participant.id, participantName: participant.name)
                }
            }
            .alert("Padam Peserta?", isPresented: $showDeleteConfirmation) {
                Button("Batal", role: .cancel) { participantToDelete = nil }
                Button("Padam", role: .destructive) {
                    if let participant = participantToDelete {
                        deleteParticipant(participant)
                    }
                }
            } message: {
                if let participant = participantToDelete {
                    Text("Adakah anda pasti mahu memadam \(participant.name)? Semua data akan turut dipadam.")
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.lightGreen.opacity(0.5), AppTheme.emerald.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Text("🌲")
                    .font(.system(size: 50))
            }
            .padding(.top, 20)

            Text("Rompin Forest Explorer")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)
                .multilineTextAlignment(.center)

            Text("Program Eksplorasi Hutan Untuk Kanak-Kanak")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.warmBeige.opacity(0.6))
                    .frame(width: 80, height: 80)

                Text("🎒")
                    .font(.system(size: 40))
            }

            Text("Tiada Peserta Lagi")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)

            Text("Tambahkan peserta pertama untuk memulakan pengalaman hutan!")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    // MARK: - Participant List

    private var participantListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.forestGreen)

                Text("Pilih Peserta")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                Spacer()

                Text("\(participants.count) orang")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.lightGreen.opacity(0.2))
                    .clipShape(Capsule())
            }

            ForEach(participants) { participant in
                ParticipantCard(
                    participant: participant,
                    hasInProgress: hasInProgressActivity(participant),
                    onSelect: {
                        selectedParticipant = participant
                        navigateToHome = true
                    },
                    onDelete: {
                        participantToDelete = participant
                        showDeleteConfirmation = true
                    }
                )
            }
        }
    }

    // MARK: - Add Participant Button

    private var addParticipantButton: some View {
        Button(action: {
            newParticipantName = ""
            selectedAvatar = "🌟"
            showAddParticipant = true
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.forestGreen.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(AppTheme.forestGreen)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Tambahkan Peserta Baru")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)

                    Text("Cipta profil untuk peserta baharu")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.forestGreen.opacity(0.4))
            }
            .padding(AppTheme.standardPadding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Add Participant Sheet

    private var addParticipantSheet: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.lightGreen.opacity(0.3))
                                .frame(width: 80, height: 80)

                            Text(selectedAvatar)
                                .font(.system(size: 44))
                        }
                        .padding(.top, 16)

                        Text("Pilih Avatar")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.secondaryText)
                    }

                    avatarPicker

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Nama Peserta")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.darkGreen)

                        TextField("Taip nama di sini...", text: $newParticipantName)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.darkGreen)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(AppTheme.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                            .stroke(AppTheme.lightGreen.opacity(0.4), lineWidth: 1.5)
                                    )
                            )
                            .accessibilityLabel("Nama peserta")
                    }

                    Button(action: addNewParticipant) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Tambah Peserta")
                                .font(AppTheme.largeButtonFont)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.buttonCornerRadius)
                                .fill(
                                    newParticipantName.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? AnyShapeStyle(AppTheme.forestGreen.opacity(0.4))
                                        : AnyShapeStyle(AppTheme.forestGreen)
                                )
                                .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .disabled(newParticipantName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.top, 8)
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 30)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Peserta Baharu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") { showAddParticipant = false }
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
    }

    // MARK: - Avatar Picker

    private var avatarPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pilih Avatar")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 64, maximum: 80))
                ],
                spacing: 14
            ) {
                ForEach(avatarOptions, id: \.self) { avatar in
                    Button(action: {
                        withAnimation(AppAnimation.fast) {
                            selectedAvatar = avatar
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    selectedAvatar == avatar
                                        ? AppTheme.lightGreen.opacity(0.5)
                                        : AppTheme.cardBackground
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            selectedAvatar == avatar
                                                ? AppTheme.forestGreen
                                                : AppTheme.dividerColor,
                                            lineWidth: selectedAvatar == avatar ? 2.5 : 1
                                        )
                                )
                                .frame(height: 72)

                            Text(avatar)
                                .font(.system(size: 34))
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .padding(AppTheme.compactPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Facilitator Mode

    private var facilitatorModeSheet: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.forestGreen.opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: "person.fill.gearshape")
                                .font(.system(size: 34, weight: .medium))
                                .foregroundColor(AppTheme.forestGreen)
                        }
                        .padding(.top, 16)

                        Text("Mod Fasilitator")
                            .font(AppTheme.headlineFont)
                            .foregroundColor(AppTheme.darkGreen)

                        Text("Urus peserta dan pantau kemajuan")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)

                    facilitatorStats

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Semua Peserta")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.darkGreen)

                        ForEach(participants) { participant in
                            facilitatorRow(for: participant)
                        }

                        if participants.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Text("👶")
                                        .font(.system(size: 32))
                                    Text("Tiada peserta")
                                        .font(AppTheme.bodyFont)
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                                .padding(.vertical, 24)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(AppTheme.cardBackground)
                            )
                        }
                    }
                    .padding(AppTheme.compactPadding)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                            .fill(AppTheme.cardBackground)
                            .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                    )
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 30)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Fasilitator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") { showFacilitatorMode = false }
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
    }

    private var facilitatorStats: some View {
        HStack(spacing: 14) {
            facilitatorStatCard(emoji: "👥", value: "\(participants.count)", label: "Peserta")
            facilitatorStatCard(emoji: "🏃", value: "\(inProgressCount)", label: "Aktif")
            facilitatorStatCard(emoji: "✅", value: "\(completedCount)", label: "Selesai")
        }
    }

    private func facilitatorStatCard(emoji: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 22))
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.forestGreen)
            Text(label)
                .font(AppTheme.smallCaption)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
        )
    }

    private func facilitatorRow(for participant: Participant) -> some View {
        HStack(spacing: 14) {
            Text(participant.avatarName ?? "🌟")
                .font(.system(size: 30))
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(participant.name)
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                let sessions = DatabaseService.shared.fetchAllSessions(participantID: participant.id, context: modelContext)
                let completed = sessions.filter(\.isCompleted).count
                Text("\(sessions.count) aktiviti · \(completed) selesai")
                    .font(AppTheme.smallCaption)
                    .foregroundColor(AppTheme.secondaryText)
            }

            Spacer()

            if hasInProgressActivity(participant) {
                Text("Aktif")
                    .font(AppTheme.smallCaption)
                    .foregroundColor(AppTheme.emerald)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.emerald.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.lightGreen.opacity(0.1))
        )
    }

    // MARK: - Helpers

    private func loadParticipants() {
        participants = DatabaseService.shared.fetchParticipants(context: modelContext)
    }

    private func hasInProgressActivity(_ participant: Participant) -> Bool {
        let sessions = DatabaseService.shared.fetchAllSessions(participantID: participant.id, context: modelContext)
        return sessions.contains { !$0.isCompleted }
    }

    private func addNewParticipant() {
        let name = newParticipantName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        _ = DatabaseService.shared.createParticipant(
            name: name,
            avatarName: selectedAvatar,
            context: modelContext
        )
        loadParticipants()
        showAddParticipant = false
    }

    private func deleteParticipant(_ participant: Participant) {
        DatabaseService.shared.deleteParticipant(participant, context: modelContext)
        loadParticipants()
    }

    private var inProgressCount: Int {
        participants.filter { hasInProgressActivity($0) }.count
    }

    private var completedCount: Int {
        participants.filter { participant in
            let sessions = DatabaseService.shared.fetchAllSessions(participantID: participant.id, context: modelContext)
            return sessions.contains { $0.isCompleted }
        }.count
    }
}

// MARK: - Participant Card

struct ParticipantCard: View {
    let participant: Participant
    let hasInProgress: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.lightGreen.opacity(0.4),
                                    AppTheme.warmBeige.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)

                    Text(participant.avatarName ?? "🌟")
                        .font(.system(size: 36))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(participant.name)
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.darkGreen)
                        .lineLimit(1)

                    if hasInProgress {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppTheme.emerald)
                                .frame(width: 8, height: 8)

                            Text("Ada aktiviti diteruskan")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.emerald)
                        }
                    } else {
                        Text("Siap untuk menerokai!")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }

                Spacer()

                VStack(spacing: 8) {
                    if hasInProgress {
                        HStack(spacing: 6) {
                            Text("Teruskan")
                                .font(AppTheme.captionFont)
                                .foregroundColor(.white)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.forestGreen)
                                .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                    } else {
                        HStack(spacing: 6) {
                            Text("Pilih")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.forestGreen)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.forestGreen)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.lightGreen.opacity(0.3))
                        )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(
                        color: isPressed
                            ? AppTheme.forestGreen.opacity(0.15)
                            : AppTheme.cardShadowColor,
                        radius: isPressed ? 12 : AppTheme.cardShadowRadius,
                        x: 0,
                        y: isPressed ? 6 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation { isPressed = true }
        } onPressingChanged: { pressing in
            withAnimation(AppAnimation.fast) {
                isPressed = pressing
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Padam Peserta", systemImage: "trash")
            }
        }
        .accessibilityLabel("\(participant.name), \(hasInProgress ? "ada aktiviti diteruskan" : "siap untuk menerokai")")
        .accessibilityHint("Taip untuk membuka profil peserta")
    }
}

// MARK: - Preview

#Preview {
    ParticipantSelectionView()
}
