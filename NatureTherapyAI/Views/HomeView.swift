import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSettings = false
    @Binding var selectedTab: Int

    init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroSection
                    quickActionsSection
                    statsRow
                    dailyChallengeSection
                    recentDiscoveriesSection
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 90)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Text("🌿")
                            .font(.system(size: 22))
                        Text("Nature Therapy")
                            .font(AppTheme.subheadline)
                            .foregroundColor(AppTheme.darkGreen)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.forestGreen)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.lightGreen.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.greeting)
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.darkGreen)

                    Text("Let's explore the wonders of nature together")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.secondaryText)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(AppTheme.lightGreen.opacity(0.4))
                        .frame(width: 72, height: 72)

                    Text("🌳")
                        .font(.system(size: 36))
                }
            }
            .padding(.top, 12)

            Button(action: { selectedTab = 1 }) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppTheme.primaryGradient)
                            .frame(width: 56, height: 56)

                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("AI Camera Scanner")
                            .font(AppTheme.subheadline)
                            .foregroundColor(.white)

                        Text("Point & Discover Nature")
                            .font(AppTheme.captionFont)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .fill(AppTheme.primaryGradient)
                        .shadow(color: AppTheme.forestGreen.opacity(0.3), radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.top, 18)
        }
    }

    private var quickActionsSection: some View {
        HStack(spacing: 14) {
            actionButton(emoji: "📖", title: "Learn", color: AppTheme.softBlue) {
                selectedTab = 2
            }

            actionButton(emoji: "🧘", title: "Therapy", color: AppTheme.softOrange) {
                selectedTab = 3
            }

            actionButton(emoji: "🏆", title: "Progress", color: AppTheme.emerald) {
                selectedTab = 4
            }
        }
    }

    private func actionButton(emoji: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Text(emoji)
                        .font(.system(size: 24))
                }

                Text(title)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.darkGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var statsRow: some View {
        HStack(spacing: 14) {
            statCard(emoji: "🔍", value: "\(viewModel.progress?.uniqueObjectsDiscovered.count ?? 0)", label: "Discovered", color: AppTheme.forestGreen)
            statCard(emoji: "⭐", value: "\(viewModel.progress?.badges.count ?? 0)", label: "Badges", color: AppTheme.softOrange)
            statCard(emoji: "🎯", value: "\(viewModel.progress?.totalActivitiesCompleted ?? 0)", label: "Activities", color: AppTheme.softBlue)
        }
    }

    private func statCard(emoji: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 22))

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Text(label)
                .font(AppTheme.smallCaption)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var dailyChallengeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.softOrange)

                Text("Daily Challenge")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                Spacer()
            }

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.softOrange.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: "eye.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.softOrange)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Find something that makes a sound")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.darkGreen)

                    Text("Observation Challenge")
                        .font(AppTheme.smallCaption)
                        .foregroundColor(AppTheme.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadowColor, radius: 4, x: 0, y: 2)
            )
            .onTapGesture { selectedTab = 3 }
        }
    }

    private var recentDiscoveriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.forestGreen)

                    Text("Recent Discoveries")
                        .font(AppTheme.subheadline)
                        .foregroundColor(AppTheme.darkGreen)
                }

                Spacer()

                Button(action: { selectedTab = 2 }) {
                    Text("See All")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.forestGreen)
                }
            }

            if viewModel.progress?.uniqueObjectsDiscovered.isEmpty ?? true {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.lightGreen)

                        Text("No discoveries yet")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)

                        Text("Use the AI Camera to identify nature!")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .fill(AppTheme.cardBackground)
                        .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(0..<min(viewModel.progress?.uniqueObjectsDiscovered.count ?? 0, 4), id: \.self) { i in
                        if let name = viewModel.progress?.uniqueObjectsDiscovered[i] {
                            let info = NatureObject.sample(for: name)
                            VStack(spacing: 8) {
                                Text(info?.emoji ?? "🌱")
                                    .font(.system(size: 32))

                                Text(name)
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.darkGreen)
                                    .lineLimit(1)

                                Text(info?.category ?? "Nature")
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
                    }
                }
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
