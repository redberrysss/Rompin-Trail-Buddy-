import SwiftUI
import SwiftData

struct StudentDiscoveriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var observations: [ObservationRecord]

    var body: some View {
        NavigationStack {
            ScrollView {
                if observations.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(observations) { item in
                            DiscoveryCardView(record: item)
                        }
                    }
                    .padding(AppTheme.standardPadding)
                }
            }
            .background(AppTheme.creamBackground.ignoresSafeArea())
            .navigationTitle("Penemuan Saya")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 80)
            Image(systemName: "binoculars.fill")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.lightGreen)

            Text("Belum ada penemuan")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)

            Text("Terokai alam dan ambil gambar\nuntuk mengumpul penemuan!")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DiscoveryCardView: View {
    let record: ObservationRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.lightGreen.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)

                if let path = record.imagePath, let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.forestGreen)
                }

                if record.isConfirmed {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundColor(AppTheme.successGreen)
                                .background(Circle().fill(.white).frame(width: 24, height: 24))
                                .padding(6)
                        }
                        Spacer()
                    }
                }
            }

            Text(record.objectName)
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)
                .lineLimit(1)

            Text(record.category)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
    }
}
