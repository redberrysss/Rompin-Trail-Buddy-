import SwiftUI
import SwiftData

struct FacilitatorReportsView: View {
    @Query private var participants: [Participant]
    @Query private var sessions: [ActivitySession]
    @Query private var observations: [ObservationRecord]
    @Query private var sensoryRecords: [SensoryRecord]
    @Query private var treasureRecords: [TreasureRecord]
    @Query private var artworks: [ArtworkRecord]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    reportSummaryCard
                    activityCompletionCard
                    recentActivityCard
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Laporan")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var reportSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(AppTheme.forestGreen)
                Text("Ringkasan Kumpulan")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }

            let totalParticipants = participants.count
            let totalSessions = sessions.count
            let completedSessions = sessions.filter { $0.isCompleted }.count
            let completionRate = totalSessions > 0 ? Double(completedSessions) / Double(totalSessions) * 100 : 0

            HStack(spacing: 0) {
                reportItem(value: "\(totalParticipants)", label: "Pelajar", icon: "person.3.fill", color: AppTheme.softBlue)
                Divider().frame(height: 40)
                reportItem(value: "\(completedSessions)", label: "Selesai", icon: "checkmark.circle.fill", color: AppTheme.successGreen)
                Divider().frame(height: 40)
                reportItem(value: "\(Int(completionRate))%", label: "Kadar", icon: "chart.line.uptrend.xyaxis", color: AppTheme.softOrange)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private func reportItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var activityCompletionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "rectangle.stack.fill")
                    .foregroundColor(AppTheme.forestGreen)
                Text("Aktiviti")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }

            let activityNames = ["Jelajah Hutan", "Aktiviti Sensori", "Treasure Hunt", "Seni Alam"]
            ForEach(Array(activityNames.enumerated()), id: \.offset) { index, name in
                let count = sessions.filter { $0.activityNumber == index + 1 && $0.isCompleted }.count
                HStack {
                    Text(name)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.darkGreen)
                    Spacer()
                    Text("\(count) selesai")
                        .font(AppTheme.captionFont)
                        .foregroundColor(count > 0 ? AppTheme.successGreen : AppTheme.secondaryText)
                }
                if index < activityNames.count - 1 {
                    Divider()
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

    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(AppTheme.forestGreen)
                Text("Aktiviti Terkini")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }

            let recentSessions = sessions.sorted(by: { ($0.startedAt) > ($1.startedAt) }).prefix(5)
            if recentSessions.isEmpty {
                Text("Belum ada aktiviti")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
            } else {
                ForEach(Array(recentSessions)) { session in
                    HStack {
                        Circle()
                            .fill(session.isCompleted ? AppTheme.successGreen : AppTheme.softOrange)
                            .frame(width: 10, height: 10)
                        Text("Aktiviti \(session.activityNumber)")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.darkGreen)
                        Spacer()
                        Text(session.isCompleted ? "Selesai" : "Dalam proses")
                            .font(AppTheme.captionFont)
                            .foregroundColor(session.isCompleted ? AppTheme.successGreen : AppTheme.softOrange)
                    }
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
}
