import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(AuthenticationViewModel.self) private var authVM
    @State private var selectedTab: Int = 0
    @State private var showAccount = false

    let participantID: UUID?
    let participantName: String?

    private var isFacilitator: Bool {
        authVM.userRole == "facilitator"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: AppTheme.tabBarHeight + 10)
                }

            floatingTabBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAccount) {
            AccountView()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        if isFacilitator {
            facilitatorTab(selectedTab)
        } else {
            studentTab(selectedTab)
        }
    }

    @ViewBuilder
    private func facilitatorTab(_ index: Int) -> some View {
        switch index {
        case 0:
            FacilitatorDashboardView()
        case 1:
            FacilitatorStudentsView()
        case 2:
            FacilitatorActivitiesView()
        case 3:
            FacilitatorReportsView()
        case 4:
            FacilitatorProfileView()
        default:
            FacilitatorDashboardView()
        }
    }

    @ViewBuilder
    private func studentTab(_ index: Int) -> some View {
        switch index {
        case 0:
            StudentHomeView(participantID: participantID ?? UUID(), participantName: participantName ?? "Peserta")
        case 1:
            StudentExploreView()
        case 2:
            StudentActivitiesView(participantID: participantID ?? UUID())
        case 3:
            StudentDiscoveriesView()
        case 4:
            StudentProfileView()
        default:
            StudentHomeView(participantID: participantID ?? UUID(), participantName: participantName ?? "Peserta")
        }
    }

    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { index in
                Button {
                    withAnimation(AppTheme.smoothEase) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: icon(for: index))
                            .font(.system(size: selectedTab == index ? 22 : 20, weight: selectedTab == index ? .semibold : .regular))
                        Text(label(for: index))
                            .font(AppTheme.smallCaption)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == index ? (isFacilitator ? AppTheme.forestGreen : AppTheme.darkGreen) : AppTheme.secondaryText)
                    .scaleEffect(selectedTab == index ? 1.05 : 1.0)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(label(for: index))
                .accessibilityAddTraits(selectedTab == index ? .isSelected : [])
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.tabBarCornerRadius)
                .fill(.regularMaterial)
                .shadow(color: AppTheme.deepShadow, radius: 16, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private func icon(for index: Int) -> String {
        if isFacilitator {
            ["house.fill", "person.2.fill", "rectangle.stack.fill", "chart.bar.fill", "person.circle.fill"][index]
        } else {
            ["house.fill", "binoculars.fill", "rectangle.stack.fill", "star.fill", "person.circle.fill"][index]
        }
    }

    private func label(for index: Int) -> String {
        if isFacilitator {
            ["Laman", "Pelajar", "Aktiviti", "Laporan", "Profil"][index]
        } else {
            ["Laman", "Teroka", "Aktiviti", "Penemuan", "Profil"][index]
        }
    }
}

// MARK: - Facilitator Tab Placeholders

struct FacilitatorActivitiesView: View {
    @Query private var sessions: [ActivitySession]

    var body: some View {
        NavigationStack {
            List {
                let activityNames = ["Jelajah Hutan", "Aktiviti Sensori", "Treasure Hunt", "Seni Alam"]
                ForEach(Array(activityNames.enumerated()), id: \.offset) { index, name in
                    let count = sessions.filter { $0.activityNumber == index + 1 }.count
                    let completed = sessions.filter { $0.activityNumber == index + 1 && $0.isCompleted }.count
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name)
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.darkGreen)
                            Text("\(count) peserta, \(completed) selesai")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.secondaryText)
                        }
                        Spacer()
                        if completed > 0 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.successGreen)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Aktiviti")
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .scrollContentBackground(.hidden)
        }
    }
}

struct FacilitatorProfileView: View {
    var body: some View {
        NavigationStack {
            AccountView()
        }
    }
}
