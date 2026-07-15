import SwiftUI
import SwiftData

struct StudentProfileView: View {
    @Environment(AuthenticationViewModel.self) private var authVM
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [ActivitySession]
    @Query private var observations: [ObservationRecord]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    statsCard
                    achievementsSection
                    badgesSection

                    logoutSection
                        .padding(.top, 8)
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Profil Saya")
            .navigationBarTitleDisplayMode(.large)
            .alert("Log Keluar", isPresented: $showLogoutConfirmation) {
                Button("Log Keluar", role: .destructive) {
                    authVM.signOut()
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Anda akan log keluar dari aplikasi. Anda perlu log masuk semula untuk menggunakan aplikasi.")
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.3))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(AppTheme.forestGreen)
            }

            Text(authVM.currentUserName ?? "Peserta")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)

            Text("Pengembara Alam")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(observations.count)", label: "Penemuan", icon: "binoculars.fill", color: AppTheme.softBlue)
            Divider().frame(height: 40)
            statItem(value: "\(sessions.filter(\.isCompleted).count)", label: "Selesai", icon: "checkmark.circle.fill", color: AppTheme.successGreen)
            Divider().frame(height: 40)
            statItem(value: "\(sessions.count)", label: "Aktiviti", icon: "rectangle.stack.fill", color: AppTheme.softOrange)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
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

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(AppTheme.softOrange)
                Text("Pencapaian")
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.darkGreen)
            }

            Text("Teruskan penerokaan untuk membuka pencapaian!")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var badgesSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            badgeItem(icon: "🌳", label: "Penjelajah", unlocked: observations.count > 0)
            badgeItem(icon: "🌿", label: "Sahabat", unlocked: sessions.count > 2)
            badgeItem(icon: "🔍", label: "Detektif", unlocked: observations.count > 2)
            badgeItem(icon: "🎨", label: "Artis", unlocked: false)
            badgeItem(icon: "⭐", label: "Juara", unlocked: sessions.filter(\.isCompleted).count > 2)
            badgeItem(icon: "🏆", label: "Master", unlocked: false)
        }
    }

    private var logoutSection: some View {
        VStack(spacing: 12) {
            Button(action: { showLogoutConfirmation = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                        .frame(width: 36, height: 36)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Circle())

                    Text("Log Keluar")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.darkGreen)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.secondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.cardBackground)
                        .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }

    @State private var showLogoutConfirmation = false

    private func badgeItem(icon: String, label: String, unlocked: Bool) -> some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 36))
                .grayscale(unlocked ? 0 : 1)
                .opacity(unlocked ? 1 : 0.4)

            Text(label)
                .font(AppTheme.captionFont)
                .foregroundColor(unlocked ? AppTheme.darkGreen : AppTheme.secondaryText)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 2)
        )
    }
}
