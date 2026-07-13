import SwiftUI
import SwiftData

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProgressViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroRingSection
                    statsGrid
                    achievementsSection
                    discoveredSection
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 90)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }

    private var heroRingSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                ProgressRing(
                    progress: min(Double(viewModel.objectsDiscoveredCount) / 10.0, 1.0),
                    color: AppTheme.forestGreen,
                    icon: "🔍",
                    label: "Discoveries"
                )

                ProgressRing(
                    progress: min(Double(viewModel.completedActivities) / 20.0, 1.0),
                    color: AppTheme.softBlue,
                    icon: "🎯",
                    label: "Activities"
                )

                ProgressRing(
                    progress: min(Double(viewModel.progress?.totalExplorationTime ?? 0) / 7200.0, 1.0),
                    color: AppTheme.softOrange,
                    icon: "⏱️",
                    label: "Exploration"
                )
            }

            if let progress = viewModel.progress {
                Text("Last active \(progress.lastActiveDate, style: .relative)")
                    .font(AppTheme.smallCaption)
                    .foregroundColor(AppTheme.secondaryText)
            }
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
        .padding(.top, 8)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 14) {
            StatCardModern(emoji: "🔍", value: "\(viewModel.objectsDiscoveredCount)",
                          label: "Found", color: AppTheme.forestGreen)
            StatCardModern(emoji: "🎯", value: "\(viewModel.completedActivities)",
                          label: "Done", color: AppTheme.softBlue)
            StatCardModern(emoji: "⏱️", value: viewModel.formattedTime,
                          label: "Time", color: AppTheme.softOrange)
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.softOrange)

                Text("Achievements")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                Spacer()

                Text("\(viewModel.earnedBadges.count)/\(Badge.allBadges.count)")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.softOrange.opacity(0.15))
                    .clipShape(Capsule())
            }

            if viewModel.earnedBadges.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "star")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.lightGreen)

                        Text("No badges yet")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)

                        Text("Explore nature to earn achievements!")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(AppTheme.cardBackground)
                        .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                )
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100, maximum: 120))
                ], spacing: 16) {
                    ForEach(viewModel.earnedBadges) { badge in
                        BadgeView(badge: badge)
                    }
                }
            }
        }
    }

    private var discoveredSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.forestGreen)

                Text("Discovery Timeline")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)
            }

            if viewModel.discoveredObjects.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.lightGreen)

                        Text("No objects discovered yet")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)

                        Text("Use AI Camera to start discovering!")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .fill(AppTheme.cardBackground)
                        .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
                )
            } else {
                ForEach(viewModel.discoveredObjects) { object in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.lightGreen.opacity(0.2))
                                .frame(width: 44, height: 44)

                            Text(object.emoji)
                                .font(.system(size: 22))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(object.name)
                                .font(AppTheme.subheadline)
                                .foregroundColor(AppTheme.darkGreen)

                            HStack(spacing: 6) {
                                Text("Seen \(object.timesSeen) times")
                                    .font(AppTheme.smallCaption)
                                    .foregroundColor(AppTheme.secondaryText)

                                Circle()
                                    .fill(AppTheme.secondaryText)
                                    .frame(width: 3, height: 3)

                                Text(object.dateDiscovered, style: .date)
                                    .font(AppTheme.smallCaption)
                                    .foregroundColor(AppTheme.secondaryText)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(AppTheme.cardBackground)
                            .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
                    )
                }
            }
        }
    }
}

struct ProgressRing: View {
    let progress: Double
    let color: Color
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                    .frame(width: 72, height: 72)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
                    .animation(AppAnimation.smooth, value: progress)

                Text(icon)
                    .font(.system(size: 20))
            }

            Text(label)
                .font(AppTheme.smallCaption)
                .foregroundColor(AppTheme.secondaryText)
        }
    }
}

struct StatCardModern: View {
    let emoji: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 22))

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(AppTheme.smallCaption)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
        )
    }
}
