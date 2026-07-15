import SwiftUI
import SwiftData

struct FacilitatorDashboardView: View {
    @Environment(AuthenticationViewModel.self) private var authVM
    @Query private var participants: [Participant]
    @Query private var sessions: [ActivitySession]
    @Query private var observations: [ObservationRecord]

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    welcomeHeader
                    statsGrid
                    quickActionsRow
                    participantsSection
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Fasilitator")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selamat datang, \(authVM.currentUserName ?? "Fasilitator")")
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.darkGreen)
                    Text("Panel kawalan kumpulan")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(AppTheme.lightGreen.opacity(0.3))
                        .frame(width: 56, height: 56)
                    Image(systemName: "person.fill.gearshape")
                        .font(.title2)
                        .foregroundColor(AppTheme.forestGreen)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var statsGrid: some View {
        let total = participants.count
        let active = sessions.filter { !$0.isCompleted }.count
        let completed = sessions.filter { $0.isCompleted }.count
        let discoveries = observations.count

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            statCard(value: "\(total)", label: "Peserta", icon: "person.3.fill", color: AppTheme.softBlue)
            statCard(value: "\(active)", label: "Aktif", icon: "play.fill", color: AppTheme.softOrange)
            statCard(value: "\(completed)", label: "Selesai", icon: "checkmark.circle.fill", color: AppTheme.successGreen)
            statCard(value: "\(discoveries)", label: "Penemuan", icon: "star.fill", color: AppTheme.softYellow)
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var quickActionsRow: some View {
        HStack(spacing: 16) {
            quickActionButton(icon: "person.badge.plus", label: "Tambah Pelajar", color: AppTheme.forestGreen)
            quickActionButton(icon: "rectangle.stack.fill", label: "Aktiviti", color: AppTheme.softBlue)
            quickActionButton(icon: "doc.text.fill", label: "Laporan", color: AppTheme.softOrange)
        }
    }

    private func quickActionButton(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color)
                        .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
                )
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.darkGreen)
        }
        .frame(maxWidth: .infinity)
    }

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(AppTheme.forestGreen)
                Text("Senarai Peserta")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
                Text("\(participants.count) orang")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }

            if participants.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.slash.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.secondaryText)
                    Text("Tiada peserta lagi")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.secondaryText)
                    Text("Peserta akan muncul selepas mereka mendaftar.")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .fill(AppTheme.cardBackground)
                )
            } else {
                ForEach(participants) { participant in
                    NavigationLink {
                        FacilitatorParticipantDetailView(participant: participant)
                    } label: {
                        participantRow(participant)
                    }
                }
            }
        }
    }

    private func participantRow(_ participant: Participant) -> some View {
        let participantSessions = sessions.filter { $0.participantID == participant.id }
        let completedSessions = participantSessions.filter { $0.isCompleted }.count
        let totalSessions = participantSessions.count
        let score = calculateScore(for: participant)

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: participant.avatarColor))
                    .frame(width: 48, height: 48)
                Text(participant.name.prefix(1).uppercased())
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(participant.name)
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                HStack(spacing: 6) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 10))
                    Text("\(totalSessions) aktiviti")
                        .font(AppTheme.captionFont)
                    if completedSessions > 0 {
                        Text("• \(completedSessions) selesai")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.successGreen)
                    }
                }
                .foregroundColor(AppTheme.secondaryText)

                if totalSessions > 0 {
                    let pct = Double(completedSessions) / Double(max(totalSessions, 1))
                    SwiftUI.ProgressView(value: pct)
                        .tint(AppTheme.forestGreen)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(score, specifier: "%.0f")%")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(scoreColor(score))
                Text("Skor")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 2)
    }

    private func calculateScore(for participant: Participant) -> Double {
        let participantSessions = sessions.filter { $0.participantID == participant.id }
        guard !participantSessions.isEmpty else { return 0 }
        let total = participantSessions.reduce(0.0) { $0 + $1.progress }
        return (total / Double(participantSessions.count)) * 100
    }

    private func scoreColor(_ score: Double) -> Color {
        score >= 80 ? AppTheme.successGreen : score >= 50 ? AppTheme.softOrange : AppTheme.gentleCoral
    }
}

extension Participant {
    var avatarColor: String {
        let colors = ["2E7D32", "2196F3", "FF9800", "9C27B0", "F44336", "00BCD4", "FF5722", "607D8B"]
        let index = abs(name.hash) % colors.count
        return colors[index]
    }
}
