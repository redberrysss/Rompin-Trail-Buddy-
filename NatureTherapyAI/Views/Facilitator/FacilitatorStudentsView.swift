import SwiftUI
import SwiftData

struct FacilitatorStudentsView: View {
    @Query private var participants: [Participant]
    @Query private var sessions: [ActivitySession]
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                if participants.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredParticipants) { participant in
                        NavigationLink {
                            FacilitatorParticipantDetailView(participant: participant)
                        } label: {
                            studentRow(participant)
                        }
                    }
                }
            }
            .navigationTitle("Pelajar")
            .searchable(text: $searchText, prompt: "Cari pelajar...")
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .scrollContentBackground(.hidden)
        }
    }

    private var filteredParticipants: [Participant] {
        if searchText.isEmpty { return participants }
        return participants.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.slash.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.secondaryText)
            Text("Tiada pelajar")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)
            Text("Pelajar akan muncul selepas mendaftar dan memulakan aktiviti.")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .listRowBackground(Color.clear)
    }

    private func studentRow(_ participant: Participant) -> some View {
        let participantSessions = sessions.filter { $0.participantID == participant.id }
        let completedSessions = participantSessions.filter { $0.isCompleted }.count
        let totalSessions = participantSessions.count
        let score = totalSessions > 0 ? (participantSessions.reduce(0.0) { $0 + $1.progress } / Double(totalSessions)) * 100 : 0

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: participant.avatarColor))
                    .frame(width: 44, height: 44)
                Text(participant.name.prefix(1).uppercased())
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(participant.name)
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                HStack(spacing: 4) {
                    ForEach(0..<4) { i in
                        Image(systemName: i < completedSessions ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.softYellow)
                    }
                    if completedSessions < 4 {
                        Text("\(completedSessions)/4")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
            }

            Spacer()

            Text("\(score, specifier: "%.0f")%")
                .font(AppTheme.headlineFont)
                .foregroundColor(score >= 80 ? .green : score >= 50 ? .orange : .red)
        }
        .padding(.vertical, 4)
    }
}
