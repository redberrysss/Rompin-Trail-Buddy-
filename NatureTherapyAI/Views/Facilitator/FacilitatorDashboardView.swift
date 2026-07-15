import SwiftUI
import SwiftData

struct FacilitatorDashboardView: View {
    @Environment(AuthenticationViewModel.self) private var authVM
    @Query private var participants: [Participant]
    @Query private var sessions: [ActivitySession]
    @Query private var observations: [ObservationRecord]
    @Query private var sensoryRecords: [SensoryRecord]
    @Query private var treasureRecords: [TreasureRecord]
    @Query private var artworks: [ArtworkRecord]

    @State private var searchText = ""
    @State private var showAccount = false

    var body: some View {
        NavigationStack {
            List {
                headerSection
                statsSection
                if filteredParticipants.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredParticipants) { participant in
                        NavigationLink {
                            FacilitatorParticipantDetailView(participant: participant)
                        } label: {
                            participantRow(participant)
                        }
                    }
                }
            }
            .navigationTitle("Fasilitator")
            .searchable(text: $searchText, prompt: "Cari peserta...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAccount = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAccount) {
                AccountView()
            }
        }
    }

    private var filteredParticipants: [Participant] {
        if searchText.isEmpty { return participants }
        return participants.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.forestGreen)
            Text("Panel Fasilitator")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)
            if let name = authVM.currentUserName {
                Text("Selamat datang, \(name)")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }

    private var statsSection: some View {
        let total = participants.count
        let active = sessions.filter { !$0.isCompleted }.count
        let completed = sessions.filter { $0.isCompleted }.count

        return VStack(spacing: 12) {
            Text("Ringkasan").font(AppTheme.bodyFont).foregroundColor(AppTheme.darkGreen)
            HStack(spacing: 20) {
                statCard(value: "\(total)", label: "Peserta", icon: "person.3.fill", color: .blue)
                statCard(value: "\(active)", label: "Aktif", icon: "play.fill", color: .orange)
                statCard(value: "\(completed)", label: "Selesai", icon: "checkmark.circle.fill", color: .green)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(AppTheme.darkGreen)
            Text(label)
                .font(AppTheme.smallCaption)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.slash.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.secondaryText)
            Text("Tiada peserta lagi")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
            Text("Peserta akan muncul selepas mereka mendaftar dan memulakan aktiviti.")
                .font(AppTheme.smallCaption)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
    }

    private func participantRow(_ participant: Participant) -> some View {
        let participantSessions = sessions.filter { $0.participantID == participant.id }
        let completedSessions = participantSessions.filter { $0.isCompleted }.count
        let totalSessions = participantSessions.count
        let score = calculateScore(for: participant)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(Color(participant.avatarColor))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(participant.name.prefix(1).uppercased())
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(participant.name)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.darkGreen)
                    Text("\(totalSessions) sesi, \(completedSessions) selesai")
                        .font(AppTheme.smallCaption)
                        .foregroundColor(AppTheme.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(score, specifier: "%.0f")%")
                        .font(.headline.bold())
                        .foregroundColor(scoreColor(score))
                    Text("Skor")
                        .font(AppTheme.smallCaption)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }

            if totalSessions > 0 {
                let pct = totalSessions > 0 ? Double(completedSessions) / Double(totalSessions) : 0
                SwiftUI.ProgressView(value: pct)
                    .tint(AppTheme.forestGreen)
            }

            let recentObs = observations.filter { $0.participantID == participant.id }
            if !recentObs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recentObs.suffix(5)) { obs in
                            if let path = obs.imagePath, let uiImage = loadImage(from: path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func calculateScore(for participant: Participant) -> Double {
        let participantSessions = sessions.filter { $0.participantID == participant.id }
        guard !participantSessions.isEmpty else { return 0 }
        let total = participantSessions.reduce(0.0) { $0 + $1.progress }
        return (total / Double(participantSessions.count)) * 100
    }

    private func scoreColor(_ score: Double) -> Color {
        score >= 80 ? .green : score >= 50 ? .orange : .red
    }

    private func loadImage(from path: String) -> UIImage? {
        ImageStorageService.shared.loadImage(at: path)
    }
}

extension Participant {
    var avatarColor: String {
        let colors = ["#4CAF50", "#2196F3", "#FF9800", "#9C27B0", "#F44336", "#00BCD4", "#FF5722", "#607D8B"]
        let index = abs(name.hash) % colors.count
        return colors[index]
    }
}
