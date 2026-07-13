import SwiftUI
import SwiftData

struct HomeDashboardView: View {
    let participantID: UUID
    let participantName: String

    @Environment(\.modelContext) private var modelContext
    @Environment(AuthenticationViewModel.self) private var authVM
    @State private var viewModel = HomeDashboardViewModel()
    @State private var showSettings = false
    @State private var showAccount = false
    @State private var showFacilitatorMode = false
    @State private var navigateToActivity: ActivityType?

    enum ActivityType: String, Identifiable {
        case observation
        case sensory
        case treasureHunt
        case natureArt

        var id: String { rawValue }

        var title: String {
            switch self {
            case .observation: return "Nature Walk – Jelajah Hutan"
            case .sensory: return "Aktiviti Sensori Alam"
            case .treasureHunt: return "Nature Treasure Hunt"
            case .natureArt: return "Seni Alam Semula Jadi"
            }
        }

        var emoji: String {
            switch self {
            case .observation: return "🌳"
            case .sensory: return "🌿"
            case .treasureHunt: return "🗺️"
            case .natureArt: return "🎨"
            }
        }

        var index: Int {
            switch self {
            case .observation: return 0
            case .sensory: return 1
            case .treasureHunt: return 2
            case .natureArt: return 3
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        greetingSection
                        progressSummarySection
                        activityGridSection
                        continueButtonSection
                        facilitatorButtonSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Rompin Forest Explorer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    syncStatusIndicator
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showAccount = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Akaun")

                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Tetapan")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showAccount) {
                AccountView()
            }
            .sheet(isPresented: $showFacilitatorMode) {
                FacilitatorModePlaceholder()
            }
            .navigationDestination(item: $navigateToActivity) { activity in
                destinationView(for: activity)
            }
            .task {
                viewModel.loadProgress(for: participantID, context: modelContext)
            }
        }
    }

    // MARK: - Sync Status

    private var syncStatusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text("Disimpan")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Peserta")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Text(participantName)
                            .font(.title2.bold())
                            .foregroundStyle(.primary)

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                        }
                        .accessibilityLabel("Tukar nama peserta")
                    }
                }

                Spacer()
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Greeting Section

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selamat datang, \(participantName)!")
                .font(.title.bold())
                .foregroundStyle(.primary)

            Text("Hari ini kita akan meneroka hutan bersama!")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Progress Summary

    private var progressSummarySection: some View {
        let completed = viewModel.completedCount

        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kemajuan Hari Ini")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(completed) daripada 4 aktiviti selesai")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 56, height: 56)

                    Circle()
                        .trim(from: 0, to: CGFloat(completed) / 4.0)
                        .stroke(
                            completed == 4 ? Color.green : Color.blue,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))

                    Text("\(completed)/4")
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                }
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Activity Grid

    private var activityGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aktiviti")
                .font(.headline)
                .foregroundStyle(.primary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(allActivities, id: \.id) { activity in
                    activityCard(for: activity)
                }
            }
        }
    }

    private var allActivities: [ActivityType] {
        [.observation, .sensory, .treasureHunt, .natureArt]
    }

    private func activityCard(for activity: ActivityType) -> some View {
        let status = viewModel.status(for: activity)

        return Button {
            navigateToActivity = activity
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Text(activity.emoji)
                    .font(.system(size: 44))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)

                Text(activity.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                statusLabel(for: status)

                if status == .inProgress {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray5))
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: geo.size.width * viewModel.progress(for: activity))
                        }
                    }
                    .frame(height: 6)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground(for: status))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(activity.title), status: \(status.accessibilityLabel)")
    }

    @ViewBuilder
    private func statusLabel(for status: ActivityStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)

            Text(status.label)
                .font(.caption)
                .foregroundStyle(status.color)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func cardBackground(for status: ActivityStatus) -> some View {
        switch status {
        case .notStarted:
            Color(.secondarySystemGroupedBackground)
        case .inProgress:
            Color.blue.opacity(0.06)
        case .completed:
            Color.green.opacity(0.06)
        case .skipped:
            Color.orange.opacity(0.06)
        }
    }

    // MARK: - Continue Button

    private var continueButtonSection: some View {
        Group {
            if let nextActivity = viewModel.firstIncompleteActivity {
                Button {
                    navigateToActivity = nextActivity
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Teruskan")
                                .font(.headline)
                            Text(nextActivity.title)
                                .font(.subheadline)
                                .opacity(0.8)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)

                    Text("Semua aktiviti selesai!")
                        .font(.headline)
                        .foregroundStyle(.green)

                    Text("Tahniah, \(participantName)! Anda telah melengkapkan semua aktiviti hari ini.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - Facilitator Button

    private var facilitatorButtonSection: some View {
        Button {
            showFacilitatorMode = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "person.2.fill")
                    .font(.headline)

                Text("Mod Fasilitator")
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
            }
            .foregroundStyle(.primary)
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Navigation Destination

    @ViewBuilder
    private func destinationView(for activity: ActivityType) -> some View {
        switch activity {
        case .observation:
            Activity1NatureWalkView(
                participantID: participantID,
                participantName: participantName
            )
        case .sensory:
            Activity2SensoryView(
                participantID: participantID,
                participantName: participantName
            )
        case .treasureHunt:
            Activity3TreasureHuntView(
                participantID: participantID,
                participantName: participantName
            )
        case .natureArt:
            Activity4NatureArtView(
                participantID: participantID,
                participantName: participantName
            )
        }
    }
}

// MARK: - Activity Status

enum ActivityStatus: Equatable {
    case notStarted
    case inProgress
    case completed
    case skipped

    var label: String {
        switch self {
        case .notStarted: return "Belum Mula"
        case .inProgress: return "Sedang Berjalan"
        case .completed: return "Selesai"
        case .skipped: return "Dilangkau"
        }
    }

    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .skipped: return .orange
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .notStarted: return "Belum mula"
        case .inProgress: return "Sedang berjalan"
        case .completed: return "Selesai"
        case .skipped: return "Dilangkau"
        }
    }
}

// MARK: - ViewModel

@Observable
class HomeDashboardViewModel {
    var completedCount: Int = 0
    var activityStatuses: [HomeDashboardView.ActivityType: ActivityStatus] = [:]
    var activityProgress: [HomeDashboardView.ActivityType: Double] = [:]
    var firstIncompleteActivity: HomeDashboardView.ActivityType?

    func loadProgress(for participantID: UUID, context: ModelContext) {
        let sessions = DatabaseService.shared.fetchAllSessions(participantID: participantID, context: context)
        var statuses: [HomeDashboardView.ActivityType: ActivityStatus] = [:]
        var progressMap: [HomeDashboardView.ActivityType: Double] = [:]
        var completed = 0

        let allTypes: [HomeDashboardView.ActivityType] = [
            .observation, .sensory, .treasureHunt, .natureArt
        ]

        for activityType in allTypes {
            let typeSessions = sessions.filter { $0.activityNumber == activityType.index + 1 }
            if let session = typeSessions.first {
                statuses[activityType] = session.isCompleted ? .completed :
                    session.progress > 0 ? .inProgress : .notStarted
                progressMap[activityType] = session.progress
                if session.isCompleted { completed += 1 }
            } else {
                statuses[activityType] = .notStarted
                progressMap[activityType] = 0
            }
        }

        self.activityStatuses = statuses
        self.activityProgress = progressMap
        self.completedCount = completed
        self.firstIncompleteActivity = allTypes.first {
            statuses[$0] == .notStarted || statuses[$0] == .inProgress
        }
    }

    func status(for activity: HomeDashboardView.ActivityType) -> ActivityStatus {
        activityStatuses[activity] ?? .notStarted
    }

    func progress(for activity: HomeDashboardView.ActivityType) -> Double {
        activityProgress[activity] ?? 0
    }
}

extension HomeDashboardView.ActivityType: CaseIterable {
    static var allCases: [HomeDashboardView.ActivityType] {
        [.observation, .sensory, .treasureHunt, .natureArt]
    }
}

// MARK: - Preview

#Preview {
    HomeDashboardView(
        participantID: UUID(),
        participantName: "Ahmad"
    )
    .modelContainer(for: Participant.self, inMemory: true)
}
