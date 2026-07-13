import SwiftUI
import SwiftData

struct DiscoveryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DiscoveryViewModel()
    @State private var searchText = ""
    @State private var selectedObject: NatureObject?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    heroSection

                    if !filteredObjects.isEmpty {
                        discoveredSection
                    } else {
                        emptyStateSection
                    }

                    knowledgeSection
                }
                .padding(.horizontal, AppTheme.standardPadding)
                .padding(.bottom, 90)
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search nature objects...")
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
            .sheet(isPresented: $showDetail) {
                if let object = selectedObject {
                    DiscoveryDetailView(natureObject: object)
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.3))
                    .frame(width: 80, height: 80)

                Text("🌍")
                    .font(.system(size: 40))
            }

            Text("Discover Nature")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.darkGreen)

            Text("Learn about the amazing plants and animals around you")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var discoveredSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.forestGreen)

                Text("Discovered")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                Spacer()

                Text("\(filteredObjects.count)")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.lightGreen.opacity(0.3))
                    .clipShape(Capsule())
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 14) {
                ForEach(filteredObjects) { object in
                    Button(action: {
                        selectedObject = object
                        showDetail = true
                    }) {
                        ObjectCard(object: object)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    private var emptyStateSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.2))
                    .frame(width: 72, height: 72)

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 30))
                    .foregroundColor(AppTheme.lightGreen)
            }

            Text("No discoveries yet")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            Text("Use the AI Camera to identify and discover nature objects around you")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var knowledgeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "book.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.forestGreen)

                Text("Nature Knowledge")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)
            }

            ForEach(NatureObject.samples.prefix(4)) { object in
                Button(action: {
                    selectedObject = object
                    showDetail = true
                }) {
                    KnowledgeRow(object: object)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    private var filteredObjects: [NatureObject] {
        if searchText.isEmpty {
            return viewModel.allDiscoveredObjects
        }
        return viewModel.allDiscoveredObjects.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct ObjectCard: View {
    let object: NatureObject

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(AppTheme.lightGreen.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Text(object.emoji)
                        .font(.system(size: 24))
                }

                Spacer()

                Text("×\(object.timesSeen)")
                    .font(AppTheme.smallCaption)
                    .foregroundColor(AppTheme.forestGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.lightGreen.opacity(0.3))
                    .clipShape(Capsule())
            }

            Text(object.name)
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            Text(object.category)
                .font(AppTheme.smallCaption)
                .foregroundColor(AppTheme.secondaryText)

            Text(object.objectDescription)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
                .lineLimit(2)
                .lineSpacing(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: 6, x: 0, y: 3)
        )
    }
}

struct KnowledgeRow: View {
    let object: NatureObject

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.lightGreen.opacity(0.2))
                    .frame(width: 48, height: 48)

                Text(object.emoji)
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(object.name)
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.darkGreen)

                Text(object.category)
                    .font(AppTheme.smallCaption)
                    .foregroundColor(AppTheme.secondaryText)

                Text(object.educationalInfo)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(1)
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

struct DiscoveryDetailView: View {
    let natureObject: NatureObject
    @Environment(\.dismiss) private var dismiss
    @State private var showFunFact = false
    @State private var funFactScale: CGFloat = 0.8

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    emojiHeroSection

                    VStack(alignment: .leading, spacing: 20) {
                        infoSection

                        if showFunFact {
                            funFactSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        educationalSection
                    }
                    .padding(.horizontal, AppTheme.standardPadding)
                    .padding(.bottom, 30)
                }
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle(natureObject.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var emojiHeroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.lightGreen.opacity(0.3), AppTheme.forestGreen.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.5))
                        .frame(width: 80, height: 80)

                    Text(natureObject.emoji)
                        .font(.system(size: 44))
                }

                Text(natureObject.name)
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.darkGreen)

                Text(natureObject.category)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(AppTheme.lightGreen.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, AppTheme.standardPadding)
        .padding(.top, 8)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Description", systemImage: "info.circle.fill")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            Text(natureObject.objectDescription)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .lineSpacing(4)

            Button(action: {
                withAnimation(AppAnimation.spring) {
                    showFunFact.toggle()
                    funFactScale = showFunFact ? 1 : 0.8
                }
            }) {
                Label(showFunFact ? "Hide Fun Fact" : "Show Fun Fact",
                      systemImage: showFunFact ? "lightbulb.fill" : "lightbulb")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.softOrange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.softOrange.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }

    private var funFactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(AppTheme.softOrange)
                Text("Fun Fact!")
                    .font(AppTheme.subheadline)
                    .foregroundColor(AppTheme.softOrange)
            }

            Text(natureObject.funFact)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .lineSpacing(4)
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.softOrange.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(funFactScale)
    }

    private var educationalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What We Learn", systemImage: "book.fill")
                .font(AppTheme.subheadline)
                .foregroundColor(AppTheme.darkGreen)

            Text(natureObject.educationalInfo)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.secondaryText)
                .lineSpacing(4)
        }
        .padding(AppTheme.standardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, x: 0, y: 4)
        )
    }
}

extension NatureObject: Identifiable {}
