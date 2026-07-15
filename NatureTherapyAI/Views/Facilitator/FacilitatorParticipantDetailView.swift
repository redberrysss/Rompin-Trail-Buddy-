import SwiftUI
import SwiftData

struct FacilitatorParticipantDetailView: View {
    let participant: Participant

    @Query private var sessions: [ActivitySession]
    @Query private var observations: [ObservationRecord]
    @Query private var sensoryRecords: [SensoryRecord]
    @Query private var treasureRecords: [TreasureRecord]
    @Query private var artworks: [ArtworkRecord]

    @State private var selectedTab = 0

    private var participantSessions: [ActivitySession] {
        sessions.filter { $0.participantID == participant.id }
    }

    private var participantObservations: [ObservationRecord] {
        observations.filter { $0.participantID == participant.id }
    }

    private var participantSensory: [SensoryRecord] {
        sensoryRecords.filter { $0.participantID == participant.id }
    }

    private var participantTreasures: [TreasureRecord] {
        treasureRecords.filter { $0.participantID == participant.id }
    }

    private var participantArtworks: [ArtworkRecord] {
        artworks.filter { $0.participantID == participant.id }
    }

    private var allImages: [(image: UIImage, label: String)] {
        var result: [(UIImage, String)] = []
        for obs in participantObservations {
            if let path = obs.imagePath, let img = ImageStorageService.shared.loadImage(at: path) {
                result.append((img, obs.objectName))
            }
        }
        for rec in participantSensory {
            if let path = rec.imagePath, let img = ImageStorageService.shared.loadImage(at: path) {
                result.append((img, "Sensori Stesen \(rec.stationNumber)"))
            }
        }
        for item in participantTreasures {
            if let path = item.imagePath, let img = ImageStorageService.shared.loadImage(at: path) {
                result.append((img, item.itemName))
            }
        }
        for art in participantArtworks {
            if let img = ImageStorageService.shared.loadImage(at: art.artworkImagePath) {
                result.append((img, "Seni: \(art.title)"))
            }
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader
                scoreSummary
                activityBreakdown
                if !allImages.isEmpty {
                    imageGallerySection
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(participant.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private var profileHeader: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.purple.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay {
                    Text(participant.name.prefix(1).uppercased())
                        .font(.largeTitle.bold())
                        .foregroundColor(.purple)
                }

            Text(participant.name)
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)

            let total = participantSessions.count
            let completed = participantSessions.filter { $0.isCompleted }.count
            Text("\(completed) / \(total) aktiviti selesai")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var scoreSummary: some View {
        let score = overallScore
        let emoji = score >= 80 ? "🌟" : score >= 50 ? "👍" : "💪"

        return VStack(spacing: 8) {
            HStack {
                Text(emoji)
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Skor Keseluruhan")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                    Text("\(score, specifier: "%.0f")%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(scoreColor(score))
                }
                Spacer()
            }
            SwiftUI.ProgressView(value: score / 100)
                .tint(scoreColor(score))
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var activityBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aktiviti").font(AppTheme.bodyFont).foregroundColor(AppTheme.darkGreen)

            let activities: [(name: String, emoji: String, progress: Double, items: Int)] = [
                ("Jelajah Hutan", "🌳", activityProgress(1), participantObservations.count),
                ("Sensori Alam", "🌿", activityProgress(2), participantSensory.count),
                ("Treasure Hunt", "🗺️", activityProgress(3), participantTreasures.count),
                ("Seni Alam", "🎨", activityProgress(4), participantArtworks.count),
            ]

            ForEach(activities.indices, id: \.self) { i in
                let act = activities[i]
                HStack {
                    Text(act.emoji).font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(act.name)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.darkGreen)
                        Text("\(act.items) item dikumpul")
                            .font(AppTheme.smallCaption)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    Spacer()
                    Text("\(act.progress * 100, specifier: "%.0f")%")
                        .font(.headline.bold())
                        .foregroundColor(scoreColor(act.progress * 100))
                }
                SwiftUI.ProgressView(value: act.progress)
                    .tint(scoreColor(act.progress * 100))
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var imageGallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Galeri Gambar (\(allImages.count))")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.darkGreen)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                ForEach(allImages.indices, id: \.self) { index in
                    VStack(spacing: 4) {
                        Image(uiImage: allImages[index].image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                        Text(allImages[index].label)
                            .font(AppTheme.smallCaption)
                            .foregroundColor(AppTheme.secondaryText)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var overallScore: Double {
        let ps = participantSessions
        guard !ps.isEmpty else { return 0 }
        return ps.reduce(0.0) { $0 + $1.progress } / Double(ps.count) * 100
    }

    private func activityProgress(_ number: Int) -> Double {
        let actSessions = participantSessions.filter { $0.activityNumber == number }
        guard !actSessions.isEmpty else { return 0 }
        return actSessions.reduce(0.0) { $0 + $1.progress } / Double(actSessions.count)
    }

    private func scoreColor(_ score: Double) -> Color {
        score >= 80 ? .green : score >= 50 ? .orange : .red
    }
}
