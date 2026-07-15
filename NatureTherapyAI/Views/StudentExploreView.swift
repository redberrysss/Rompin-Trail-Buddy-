import SwiftUI
import SwiftData

struct StudentExploreView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    exploreHeader
                    categoryGrid
                    recentDiscoveries
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Teroka")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showCamera) {
                CameraView()
            }
        }
    }

    private var exploreHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "binoculars.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.forestGreen)

            Text("Apa yang anda nampak?")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)

            Text("Gunakan kamera untuk terokai alam sekitar")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "Buka Kamera", icon: "camera.fill") {
                showCamera = true
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.lightGreen.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .stroke(AppTheme.lightGreen, lineWidth: 1)
                )
        )
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            categoryCard(emoji: "🌳", title: "Pokok", description: "Pelbagai jenis pokok")
            categoryCard(emoji: "🌸", title: "Bunga", description: "Bunga berwarna-warni")
            categoryCard(emoji: "🦋", title: "Serangga", description: "Serangga kecil")
            categoryCard(emoji: "🐦", title: "Burung", description: "Burung di hutan")
        }
    }

    private func categoryCard(emoji: String, title: String, description: String) -> some View {
        VStack(spacing: 10) {
            Text(emoji)
                .font(.system(size: 44))

            Text(title)
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            Text(description)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var recentDiscoveries: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Penemuan Terkini")
                .font(AppTheme.headlineFont)
                .foregroundColor(AppTheme.darkGreen)

            Text("Belum ada penemuan. Mulakan penerokaan!")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(AppTheme.cardBackground)
                )
        }
    }
}
