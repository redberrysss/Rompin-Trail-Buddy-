import SwiftUI
import SwiftData

struct StudentHomeView: View {
    let participantID: UUID
    let participantName: String

    @Environment(\.modelContext) private var modelContext
    @Environment(AuthenticationViewModel.self) private var authVM
    @State private var navigateToActivity: ActivityType?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    welcomeCard
                    todayScheduleCard
                    currentActivityCard
                    quickActions
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 10) {
                        Image(systemName: "leaf.fill")
                            .font(.title3)
                            .foregroundColor(AppTheme.forestGreen)
                        Text("Rompin Explorer")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.darkGreen)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        navigateToActivity = nil
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.softBlue)
                    }
                    .accessibilityLabel("Bantuan")
                }
            }
            .navigationDestination(item: $navigateToActivity) { activity in
                destinationView(for: activity)
            }
        }
    }

    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hai, \(participantName)!")
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.darkGreen)
                    Text("Sedia untuk meneroka alam hari ini?")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.secondaryText)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(AppTheme.lightGreen.opacity(0.3))
                        .frame(width: 60, height: 60)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 32))
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

    private var todayScheduleCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "calendar.day.timeline.left")
                    .foregroundColor(AppTheme.forestGreen)
                Text("Jadual Hari Ini")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }

            VStack(spacing: 10) {
                scheduleRow(number: 1, title: "Jelajah Hutan", emoji: "🌳", isActive: true)
                scheduleRow(number: 2, title: "Aktiviti Sensori", emoji: "🌿", isActive: false)
                scheduleRow(number: 3, title: "Treasure Hunt", emoji: "🗺️", isActive: false)
                scheduleRow(number: 4, title: "Seni Alam", emoji: "🎨", isActive: false)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private func scheduleRow(number: Int, title: String, emoji: String, isActive: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isActive ? AppTheme.forestGreen : AppTheme.dividerColor)
                    .frame(width: 36, height: 36)
                Text(emoji)
                    .font(.system(size: 16))
            }

            Text(title)
                .font(AppTheme.bodyFont)
                .foregroundColor(isActive ? AppTheme.darkGreen : AppTheme.secondaryText)

            Spacer()

            if isActive {
                Text("Sekarang")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.forestGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(AppTheme.lightGreen.opacity(0.3))
                    .clipShape(Capsule())
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(AppTheme.dividerColor)
            }
        }
        .padding(.vertical, 4)
    }

    private var currentActivityCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "play.fill")
                    .foregroundColor(AppTheme.forestGreen)
                Text("Aktiviti Semasa")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)
                Spacer()
            }

            VStack(spacing: 10) {
                Image(systemName: "tree.fill")
                    .font(.system(size: 48))
                    .foregroundColor(AppTheme.emerald)

                Text("Jelajah Hutan")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)

                Text("Berjalan dan terokai alam sekitar")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(AppTheme.softYellow)
                    }
                }
            }

            PrimaryButton(title: "Mulakan Aktiviti", icon: "arrow.right") {
                navigateToActivity = .observation
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.lightGreen.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .stroke(AppTheme.lightGreen, lineWidth: 1)
                )
        )
    }

    private var quickActions: some View {
        HStack(spacing: 16) {
            quickActionButton(icon: "star.fill", label: "Penemuan", color: AppTheme.softYellow)
            quickActionButton(icon: "camera.fill", label: "Kamera", color: AppTheme.softBlue)
            quickActionButton(icon: "trophy.fill", label: "Pencapaian", color: AppTheme.softOrange)
            quickActionButton(icon: "face.smiling.fill", label: "Emosi", color: AppTheme.lavender)
        }
    }

    private func quickActionButton(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                        .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
                )

            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.darkGreen)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func destinationView(for activity: ActivityType) -> some View {
        switch activity {
        case .observation:
            Activity1NatureWalkView(participantID: participantID, participantName: participantName)
        case .sensory:
            Activity2SensoryView(participantID: participantID, participantName: participantName)
        case .treasureHunt:
            Activity3TreasureHuntView(participantID: participantID, participantName: participantName)
        case .natureArt:
            Activity4NatureArtView(participantID: participantID, participantName: participantName)
        }
    }

    enum ActivityType: String, Identifiable {
        case observation, sensory, treasureHunt, natureArt
        var id: String { rawValue }
    }
}
