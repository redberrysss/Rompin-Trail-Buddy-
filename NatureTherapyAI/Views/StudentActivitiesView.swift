import SwiftUI
import SwiftData

struct StudentActivitiesView: View {
    let participantID: UUID

    @Environment(\.modelContext) private var modelContext
    @State private var navigateToActivity: ActivityType?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    activitiesHeader
                    activityGrid
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Aktiviti")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $navigateToActivity) { activity in
                destinationView(for: activity)
            }
        }
    }

    private var activitiesHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 36))
                .foregroundColor(AppTheme.forestGreen)
            Text("Aktiviti Eksplorasi")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)
            Text("Lengkapkan semua aktiviti untuk menjadi Nature Master!")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var activityGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            activityCard(number: 1, title: "Jelajah Hutan", emoji: "🌳", description: "Terokai alam sekitar", color: AppTheme.forestGreen)
            activityCard(number: 2, title: "Aktiviti Sensori", emoji: "🌿", description: "Gunakan deria anda", color: AppTheme.softBlue)
            activityCard(number: 3, title: "Nature Treasure Hunt", emoji: "🗺️", description: "Cari objek tersembunyi", color: AppTheme.softOrange)
            activityCard(number: 4, title: "Seni Alam", emoji: "🎨", description: "Hasilkan karya seni", color: AppTheme.lavender)
        }
    }

    private func activityCard(number: Int, title: String, emoji: String, description: String, color: Color) -> some View {
        Button {
            navigateToActivity = ActivityType.allCases[number - 1]
        } label: {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 44))

                VStack(spacing: 4) {
                    Text(title)
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text(description)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 2) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(AppTheme.softYellow)
                    }
                }
                .opacity(0.5)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    @ViewBuilder
    private func destinationView(for activity: ActivityType) -> some View {
        switch activity {
        case .observation:
            Activity1NatureWalkView(participantID: participantID, participantName: "Peserta")
        case .sensory:
            Activity2SensoryView(participantID: participantID, participantName: "Peserta")
        case .treasureHunt:
            Activity3TreasureHuntView(participantID: participantID, participantName: "Peserta")
        case .natureArt:
            Activity4NatureArtView(participantID: participantID, participantName: "Peserta")
        }
    }

    enum ActivityType: String, Identifiable, CaseIterable {
        case observation, sensory, treasureHunt, natureArt
        var id: String { rawValue }
    }
}
